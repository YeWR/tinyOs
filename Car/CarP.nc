#include <msp430usart.h>
#include "BlinkToRadio.h"

module CarP @safe() {
	provides {
    interface Car;
	}
  uses {
    interface HplMsp430Usart;
    interface HplMsp430UsartInterrupts;
    interface Resource;
    interface HplMsp430GeneralIO;
    interface Timer<TMilli> as Timer0;
  }
} implementation{
    msp430_uart_union_config_t config1 = {
        {
            utxe: 1,
            urxe: 1,
            ubr: UBR_1MHZ_115200,       // Baud rate (use enum msp430_uart_rate_t for predefined rates)
            umctl: UMCTL_1MHZ_115200,   // Modulation (use enum msp430_uart_rate_t for predefined rates)
            ssel: 0x02,                 // Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
            pena: 0,                    // Parity enable (0=disabled; 1=enabled)
            pev: 0,                     // Parity select (0=odd; 1=even)
            spb: 0,                     // Stop bits (0=one stop bit; 1=two stop bits)
            clen: 1,                    // Character length (0=7-bit data; 1=8-bit data)
            listen: 0,                  // Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
            mm: 0,                      // Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
            ckpl: 0,                    // Clock polarity (0=normal; 1=inverted)
            urxse: 0,                   // Receive-edge detection (0=disabled; 1=enabled)
            urxeie: 0,                  // Errorneous-character receive (0=rejected; 1=received and URXIFGx set)
            urxwie: 0,                  // Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)
            utxe: 1,                    // 1: enable tx module
            urxe: 1                     // 1: enable rx module
        }
    };

    uint8_t type;
    uint16_t m_value;
    uint16_t max_speed;
    uint16_t min_speed;
    uint16_t min_angel;
    uint16_t max_angel;
    uint16_t angel1;
    uint16_t angel2;
    uint16_t angel3;
    uint8_t homing_cnt;

    event void Timer0.fired() {
        homing_cnt++;
        switch(homing_cnt) {
        case 1:
            angel1 = 3200;
            m_value = angel1;
            call Car.InitLeftServo(angel1);
            call Timer0.startOneShot(400);
            break;
        case 2:
            angel2 = 2400;
            m_value = angel2;
            call Car.InitMidServo(angel2);
            call Timer0.startOneShot(400);
            break;
        case 3:
            angel3 = 3200;
            m_value = angel3;
            call Car.InitRightServo(angel3);
            call Timer0.startOneShot(400);
            break;
        default:
            homing_cnt = 0;
            break;
        }
    }

    async event void HplMsp430UsartInterrupts.rxDone(uint8_t data) {
    }

    async event void HplMsp430UsartInterrupts.txDone() {
    }

    command void Car.start() {
        angel1 = 3200;
        angel2 = 2400;
        angel3 = 3200;
        min_angel = 1600;
        max_angel = 4800;
        homing_cnt = 0;
        call Car.InitMaxSpeed(1200);
        call Car.InitMinSpeed(0);
        call Timer0.startOneShot(400);
    }

    command error_t Car.Angle(uint16_t value) {
        atomic {
            type = 0x01;
            if (value == 1) {
                angel1 -= 400;
                if (angel1 < min_angel) {
                    angel1 = min_angel;
                }
            } 
            else if (value == 0) {
                angel1 += 400;
                if (angel1 > max_angel) {
                    angel1 = max_angel;
                }
            } 
            else if (value >= min_angel) {
                angel1 = value;
            }
        }
        m_value = angel1;
        return call Resource.request();
  }

    command error_t Car.Angle_Senc(uint16_t value) {
        atomic {
            type = 0x07;
            if (value == 1) {
                angel2 -= 400;
                if (angel2 < min_angel) {
                    angel2 = min_angel;
                }
            } 
            else if (value == 0) {
                angel2 += 400;
                if (angel2 > max_angel) {
                    angel2 = max_angel;
                }
            } 
            else if (value >= min_angel) {
                angel2 = value;
            }
            m_value = angel2;
        }
        return call Resource.request();
    }

    command error_t Car.Angle_Third(uint16_t value) {
        atomic {
            type = 0x08;
            if (value == 1) {
                angel3 -= 400;
                if (angel3 < min_angel) {
                    angel3 = min_angel;
                }
            } 
            else if (value == 0) {
                angel3 += 400;
                if (angel3 > max_angel) {
                    angel3 = max_angel;
                }
            } 
            else if (value >= min_angel) {
                angel3 = value;
            }
            m_value = angel3;
        }
        return call Resource.request();
    }

    command error_t Car.Forward(uint16_t value) {
        atomic {
            type = 0x02;
            if (value < min_speed)
                value = min_speed;
            if (value > max_speed)
                value = max_speed;
            m_value = value;
        }
        return call Resource.request();
    }

    command	error_t Car.Backward(uint16_t value) {
        atomic {
            type = 0x03;
            if (value < min_speed)
                value = min_speed;
            if (value > max_speed)
                value = max_speed;
            m_value = value;
        }
        return call Resource.request();
    }

    command	error_t Car.Left(uint16_t value) {
        atomic {
            type = 0x04;
            m_value = value;
        }
        return call Resource.request();
    }

    command	error_t Car.Right(uint16_t value) {
        atomic {
            type = 0x05;
            m_value = value;
        }
        return call Resource.request();
    }

    command	error_t Car.Pause() {
        atomic {
            type = 0x06;
            m_value = 0x0000;
        }
        return call Resource.request();
    }

    command error_t Car.InitAll() {
        error_t error = SUCCESS;
        call Timer0.startOneShot(300);
        return error;
    }

    command	error_t Car.InitMaxSpeed(uint16_t value) {
        max_speed = value;
        return SUCCESS;
    }

    command	error_t Car.InitMinSpeed(uint16_t value) {
        min_speed = value;
        return SUCCESS;
    }

    command	error_t Car.InitLeftServo(uint16_t value) {
        atomic {
            type = 0x01;
            m_value = value;
        }
        return call Resource.request();
    }

    command	error_t Car.InitMidServo(uint16_t value) {
        atomic {
            type = 0x07;
            m_value = value;
        }
        return call Resource.request();
    }

    command	error_t Car.InitRightServo(uint16_t value) {
        atomic {
            type = 0x08;
            m_value = value;
        }
        return call Resource.request();
    }

    event void Resource.granted() {
        call HplMsp430Usart.setModeUart(&config1);
        call HplMsp430Usart.enableUart();
        atomic {
            U0CTL &= ~SYNC;
            call HplMsp430Usart.tx(0x01);
            while (!call HplMsp430Usart.isTxEmpty());
            call HplMsp430Usart.tx(0x02);
            while (!call HplMsp430Usart.isTxEmpty());
            call HplMsp430Usart.tx(type);
            while (!call HplMsp430Usart.isTxEmpty());
            call HplMsp430Usart.tx(m_value / 256);
            while (!call HplMsp430Usart.isTxEmpty());
            call HplMsp430Usart.tx(m_value % 256);
            while (!call HplMsp430Usart.isTxEmpty());
            call HplMsp430Usart.tx(0xFF);
            while (!call HplMsp430Usart.isTxEmpty());
            call HplMsp430Usart.tx(0xFF);
            while (!call HplMsp430Usart.isTxEmpty());
            call HplMsp430Usart.tx(0x00);
            while (!call HplMsp430Usart.isTxEmpty());
        }
        call Resource.release();
    }
}