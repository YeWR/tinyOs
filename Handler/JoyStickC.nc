#include <Msp430Adc12.h>

configuration JoyStickC {
    provides {
		interface Read<uint16_t> as ReadX;
		interface Read<uint16_t> as ReadY;
	}
}

implementation {
    components JoyStickP;
    components new AdcReadClientC() as AdcX;
	components new AdcReadClientC() as AdcY;
    ReadX = AdcX;
	ReadY = AdcY;
	AdcX.AdcConfigure -> JoyStickP.AdcConfigX;
	AdcY.AdcConfigure -> JoyStickP.AdcConfigY;
}