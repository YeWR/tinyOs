// $Id: BlinkToRadio.h,v 1.4 2006-12-12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
  AM_CONTROLLER = 88,
  THRESHOLD = 1600,
  XMIN = THRESHOLD,
  XMAX = 4095 - THRESHOLD,
  YMIN = THRESHOLD,
  YMAX = 4095 - THRESHOLD,
  INTERVAL = 100
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint8_t type;
  nx_uint16_t value;
} BlinkToRadioMsg;

#endif
