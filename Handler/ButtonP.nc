module ButtonP {
    provides {
        interface AdcConfigure<const msp430adc12_channel_config_t*> as AdcConfigX;
        interface AdcConfigure<const msp430adc12_channel_config_t*> as AdcConfigY;
    }
}

implementation {
    
}