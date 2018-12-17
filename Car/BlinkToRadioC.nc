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
  uses interface Car;
}
implementation {

  
  const uint16_t ANGLE = 0x01;
  const uint16_t FORWARD = 0x02;
  const uint16_t BACKWARD = 0x03;
  const uint16_t LEFT = 0x04;
  const uint16_t RIGHT = 0x05;
  const uint16_t PAUSE = 0x06;
  const uint16_t ANGLE_SENC = 0x07;
  const uint16_t ANGLE_THIRD = 0x08;
  const uint16_t INITALL = 0x09;
  
  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;

  void setLeds(uint16_t val) {
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

  event void Boot.booted() {
    call AMControl.start();
    call Leds.set(7);
    call Car.start();
    call Timer0.startOneShot(1500);
  }

  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event void Timer0.fired() {
    switch(counter) {
      case 0:
        call Car.Forward(800);
        call Leds.set(FORWARD);
        //Leds.set(FORWARD);
        break;
      case 1:
        call Car.Backward(800);
        call Leds.set(BACKWARD);
        break;
      case 2:
        call Car.Left(800);
        call Leds.set(LEFT);
        break;
      case 3:
        call Car.Right(800);
        call Leds.set(RIGHT);
        break;
      case 4:
        call Car.Pause();
        call Leds.set(PAUSE);
        break;
      case 5:
        call Car.Angle(2400);
        call Leds.set(ANGLE);
        break;
      case 6:
        call Car.Angle(4400);
        call Leds.set(ANGLE);
        break;
      case 7:
        call Car.Angle_Senc(2400);
        call Leds.set(ANGLE_SENC);
        break;
      case 8:
        call Car.Angle_Senc(4400);
        call Leds.set(ANGLE_SENC);
        break;
      case 9:
        call Car.Angle_Third(2400);
        call Leds.set(ANGLE_THIRD);
        break;
      case 10:
        call Car.Angle_Third(4400);
        call Leds.set(ANGLE_THIRD);
        break;
      case 11:
        call Car.InitAll();
        call Leds.set(INITALL);
        break;
    }
    counter++;
    if (counter < 12) {
      call Timer0.startOneShot(2000);
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(BlinkToRadioMsg)) {
      
      BlinkToRadioMsg* local_data = (BlinkToRadioMsg*)payload;

      setLeds(local_data->type);

      switch (local_data->type) {
        case 0x01:
          call Car.Angle(local_data->value);
          break;
        case 0x02:
          call Car.Forward(local_data->value);
          break;
        case 0x03:
          call Car.Backward(local_data->value);
          break;
        case 0x04:
          call Car.Left(local_data->value);
          break;
        case 0x05:
          call Car.Right(local_data->value);
          break;
        case 0x06:
          call Car.Pause();
          break;
        case 0x07:
          call Car.Angle_Senc(local_data->value);
          break;
        case 0x08:
          call Car.Angle_Third(local_data->value);
          break;
        case 0x10:
          call Car.InitAll();
          break;
      }
    }
    return msg;
  }
}
