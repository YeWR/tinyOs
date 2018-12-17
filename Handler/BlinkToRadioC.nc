// $Id: BlinkToRadioC.nc,v 1.6 2010-06-29 22:07:40 scipio Exp $

/*
 * Copyright (c) 2000-2006 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include <Timer.h>
#include <Msp430Adc12.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface Read<uint16_t> as ReadX;
  uses interface Read<uint16_t> as ReadY;
  uses interface Button;
}
implementation {
  bool status[6] = {TRUE,TRUE,TRUE,TRUE,TRUE,TRUE};
  int counter = 0;
  uint16_t MOVE_SPEED = 500;
  uint8_t led = 0x00;
  uint16_t posX;
  uint16_t posY;
  bool busy = FALSE;
  message_t pkt;
  
  void setLeds(uint8_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }
  
  
  void getInputs(){
      call ReadX.read();
      call ReadY.read();
      call Button.readA();
      call Button.readB();
      call Button.readC();
      call Button.readD();
      call Button.readE();
      call Button.readF();
  }
  
  void sendInstruct(){
    BlinkToRadioMsg* sndPayload;
    bool flag = FALSE;
    sndPayload = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));

    //检验按钮
    if (status[0] == FALSE){
      led = 0x01;
      sndPayload->type = 0x01;
      sndPayload->value = 0;
      flag = TRUE;
    }
    else if (status[1] == FALSE){
      led = 0x02;
      sndPayload->type = 0x01;
      sndPayload->value = 1;
      flag = TRUE;
    }
    else if (status[2] == FALSE){
      led = 0x03;
      sndPayload->type = 0x07;
      sndPayload->value = 1;
      flag = TRUE;
    }
    else if (status[4] == FALSE ){
      led = 0x05;
      sndPayload->type = 0x07;
      sndPayload->value = 0;
      flag = TRUE;
    }
    else if ( status[5] == FALSE ){
      led = 0x06;
      sndPayload->type = 0x10;
      sndPayload->value = 0;
      flag = TRUE;
    }

    //检验摇杆
    if (flag == FALSE) {
      if ( posY < 500 ){ //前进
        led = 0x01;
        sndPayload->type = 0x02;
        sndPayload->value = MOVE_SPEED;
      }
      else if ( posY > 3500 ){  //后退
        led = 0x02;
        sndPayload->type = 0x03;
        sndPayload->value = MOVE_SPEED;
      }      
      else if (posX > 3500 ){  //左转
        led = 0x03;
        sndPayload->type = 0x05;
        sndPayload->value = MOVE_SPEED;
      }
      else if (posX < 500 ){  //右转
        led = 0x04;
        sndPayload->type = 0x04;
        sndPayload->value = MOVE_SPEED;
      }
      else {  //停止
        led = 0x05;
        sndPayload->type = 0x06;
        sndPayload->value = 0;
      }
    }

    status[0]=status[1]=status[2]=status[3]=status[4]=status[5]=TRUE;
    if (!busy) {
      if (sndPayload == NULL) {
        return;
      }
      setLeds(led);
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }
  
  void addInstruct(){
      counter ++;
      if(counter >= 8){
          counter = 0;
          sendInstruct();
      }
  }
  
  event void Boot.booted() {
    call AMControl.start();
    call Button.start();
    call Leds.led0On();
    call Leds.led1On();
    call Leds.led2On();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {}
  
  
  event void Timer0.fired() {
    getInputs();
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }
  
  
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
    }
    return msg;
  }
  
  event void ReadX.readDone(error_t error, uint16_t val){
      if(error==SUCCESS){
          posX = val;
          addInstruct();
      }
  }
  
  event void ReadY.readDone(error_t error, uint16_t val){
      if(error==SUCCESS){
          posY = val;
          addInstruct();
      }
  }
  
  event void Button.startDone(error_t err){}
  
  event void Button.stopDone(error_t err){}
  
  event void Button.readADone(error_t err, bool val){
      if(err == SUCCESS){
          status[0] = val;
          addInstruct();
      }
  }
  event void Button.readBDone(error_t err, bool val){
      if(err == SUCCESS){
          status[1] = val;
          addInstruct();
      }
  }
  event void Button.readCDone(error_t err, bool val){
      if(err == SUCCESS){
          status[2] = val;
          addInstruct();
      }
  }
  event void Button.readDDone(error_t err, bool val){
      if(err == SUCCESS){
          status[3] = val;
          addInstruct();
      }
  }
  event void Button.readEDone(error_t err, bool val){
      if(err == SUCCESS){
          status[4] = val;
          addInstruct();
      }
  }
  event void Button.readFDone(error_t err, bool val){
      if(err == SUCCESS){
          status[5] = val;
          addInstruct();
      }
  }
}
















