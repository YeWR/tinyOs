module ButtonP {
    provides interface Button;
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
        error_t err = SUCCESS;
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
        
        signal Button.startDone(err);
    }
    
    command void Button.stop(){
        error_t err = SUCCESS;
        signal Button.startDone(err);
    }
    
    command void Button.readA(){
        error_t err = SUCCESS;
        A_isPressed = call A_button.get();
        signal Button.readADone(err, A_isPressed);
    }

    command void Button.readB(){
        error_t err = SUCCESS;
        B_isPressed = call B_button.get();
        signal Button.readBDone(err, B_isPressed);
    }
    
    command void Button.readC(){
        error_t err = SUCCESS;
        C_isPressed = call C_button.get();
        signal Button.readCDone(err, C_isPressed);
    }

    command void Button.readD(){
        error_t err = SUCCESS;
        D_isPressed = call D_button.get();
        signal Button.readDDone(err, D_isPressed);
    }

    command void Button.readE(){
        error_t err = SUCCESS;
        E_isPressed = call E_button.get();
        signal Button.readEDone(err, E_isPressed);
    }
    
    command void Button.readF(){
        error_t err = SUCCESS;
        F_isPressed = call F_button.get();
        signal Button.readFDone(err, F_isPressed);
    }
    
}