module ButtonP {
    provides {
        interface AdcConfigure<const msp430adc12_channel_config_t*> as AdcConfigX;
        interface AdcConfigure<const msp430adc12_channel_config_t*> as AdcConfigY;
    }
    provides interface Button
    uses{
        interface HplMsp430GeneralIO as A_button;
        interface HplMsp430GeneralIO as B_button;
        interface HplMsp430GeneralIO as C_button;
        interface HplMsp430GeneralIO as D_button;
        interface HplMsp430GeneralIO as E_button;
        interface HplMsp430GeneralIO as F_button;
    }
}

implementation {
    bool A_isPressed;
    bool B_isPressed;
    bool C_isPressed;    
    bool D_isPressed;
    bool E_isPressed;    
    bool F_isPressed;

    command void Button.start(){
        error_t error = SUCCESS;
        call A_button.clr();
        call B_button.clr();
        call C_button.clr();
        call D_button.clr();
        call E_button.clr();
        call F_button.clr();
        
        call A_button.makeInput();
        call B_button.makeInput();
        call C_button.makeInput();
        call D_button.makeInput();
        call E_button.makeInput();
        call F_button.makeInput();
        
        signal Button.startDone(error);
    }
    
    command void Button.stop(){
        error_t error = SUCCESS;
        signal Button.startDone(error);
    }
    
    command void Button.pinvalueA(){
        error_t error = SUCCESS;
        A_isPressed = call A_button.get();
        signal Button.pinvalueADone(error, A_isPressed);
    }

    command void Button.pinvalueB(){
        error_t error = SUCCESS;
        B_isPressed = call B_button.get();
        signal Button.pinvalueBDone(error, B_isPressed);
    }
    
    command void Button.pinvalueC(){
        error_t error = SUCCESS;
        C_isPressed = call C_button.get();
        signal Button.pinvalueCDone(error, C_isPressed);
    }

    command void Button.pinvalueD(){
        error_t error = SUCCESS;
        D_isPressed = call D_button.get();
        signal Button.pinvalueDDone(error, D_isPressed);
    }

    command void Button.pinvalueE(){
        error_t error = SUCCESS;
        E_isPressed = call E_button.get();
        signal Button.pinvalueEDone(error, E_isPressed);
    }
    
    command void Button.pinvalueF(){
        error_t error = SUCCESS;
        F_isPressed = call F_button.get();
        signal Button.pinvalueFDone(error, F_isPressed);
    }
    
}