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

/**
 * Implementation of the BlinkToRadio application.  A counter is
 * incremented and a radio message is sent whenever a timer fires.
 * Whenever a radio message is received, the three least significant
 * bits of the counter in the message payload are displayed on the
 * LEDs.  Program two motes with this application.  As long as they
 * are both within range of each other, the LEDs on both will keep
 * changing.  If the LEDs on one (or both) of the nodes stops changing
 * and hold steady, then that node is no longer receiving any messages
 * from the other node.
 *
 * @author Prabal Dutta
 * @date   Feb 1, 2006
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
  bool buttons[6] = {TRUE,TRUE,TRUE,TRUE,TRUE,TRUE};
  int counter = 0;
  uint16_t MOVE_SPEED = 500;
  uint8_t instruct = 0x00;
  uint8_t led = 0x00;
  uint16_t joystickX;
  uint16_t joystickY;
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
  
  void ledShow(){
      setLeds(led);
  }
  
  void getInputs(){
      call ReadX.read();
      call ReadY.read();
      call Button.pinvalueA();
      call Button.pinvalueB();
      call Button.pinvalueC();
      call Button.pinvalueD();
      call Button.pinvalueE();
      call Button.pinvalueF();
  }
  
  void sendInstruct(){
      BlinkToRadioMsg* sndPayload;
      bool flag = FALSE;
    sndPayload = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));

    //检验按钮
        if (buttons[0] == FALSE){ //舵机1 smaller
          led = 0x01;
          instruct = 0x01;
          sndPayload->type = 0x01;
          sndPayload->value = 0;
          flag = TRUE;
        }
        else if (buttons[1] == FALSE){ //舵机1 bigger
          led = 0x02;
          instruct = 0x01;
          sndPayload->type = 0x01;
          sndPayload->value = 1;
          flag = TRUE;
        }
        else if (buttons[2] == FALSE){ //舵机2 smaller
          led = 0x03;
          instruct = 0x07;
          sndPayload->type = 0x07;
          sndPayload->value = 1;
          flag = TRUE;
        }
        else if (buttons[4] == FALSE ){ //duoji2 bigger
          led = 0x05;
          instruct = 0x08;
          sndPayload->type = 0x07;
          sndPayload->value = 0;
          flag = TRUE;
        }
        else if ( buttons[5] == FALSE ){ //reset
          led = 0x06;
          instruct = 0x10;
          sndPayload->type = 0x10;
          sndPayload->value = 0;
          flag = TRUE;
        }

    //检验摇杆
    if (flag == FALSE) {
      if ( joystickY < 500 ){ //前进
        led = 0x01;
        instruct = 0x02;
        sndPayload->type = 0x02;
        sndPayload->value = MOVE_SPEED;
      }
      else if ( joystickY > 3500 ){  //后退
        led = 0x02;
        instruct = 0x03;
        sndPayload->type = 0x03;
        sndPayload->value = MOVE_SPEED;
      }      
      else if (joystickX > 3500 ){  //左转
        led = 0x03;
        instruct = 0x04;
        sndPayload->type = 0x05;
        sndPayload->value = MOVE_SPEED;
      }
      else if (joystickX < 500 ){  //右转
        led = 0x04;
        instruct = 0x05;
        sndPayload->type = 0x04;
        sndPayload->value = MOVE_SPEED;
      }
      else {  //停止
        led = 0x05;
        instruct = 0x06;  
        sndPayload->type = 0x06;
        sndPayload->value = 0;
      }
    }

    buttons[0]=buttons[1]=buttons[2]=buttons[3]=buttons[4]=buttons[5]=TRUE;
    if (!busy) {
      if (sndPayload == NULL) {
        return;
      }
    
      ledShow();
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
      else
      {
        setLeds(7);
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

  event void AMControl.stopDone(error_t err) {
  }
  
  
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
          joystickX = val;
          addInstruct();
      }
  }
  
  event void ReadY.readDone(error_t error, uint16_t val){
      if(error==SUCCESS){
          joystickY = val;
          addInstruct();
      }
  }
  
  event void Button.startDone(error_t error){
  }
  
  event void Button.stopDone(error_t error){
  }
  
  event void Button.pinvalueADone(error_t error, bool val){
      if(error == SUCCESS){
          buttons[0] = val;
          addInstruct();
      }
  }
  event void Button.pinvalueBDone(error_t error, bool val){
      if(error == SUCCESS){
          buttons[1] = val;
          addInstruct();
      }
  }
  event void Button.pinvalueCDone(error_t error, bool val){
      if(error == SUCCESS){
          buttons[2] = val;
          addInstruct();
      }
  }
  event void Button.pinvalueDDone(error_t error, bool val){
      if(error == SUCCESS){
          buttons[3] = val;
          addInstruct();
      }
  }
  event void Button.pinvalueEDone(error_t error, bool val){
      if(error == SUCCESS){
          buttons[4] = val;
          addInstruct();
      }
  }
  event void Button.pinvalueFDone(error_t error, bool val){
      if(error == SUCCESS){
          buttons[5] = val;
          addInstruct();
      }
  }
}
















