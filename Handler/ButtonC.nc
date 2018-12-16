/*button config*/
configuration ButtonC{
    provides interface Button;
}
implementation{
    components ButtonP;
    components HplMsp430GeneralIOC as IOC;

    Button = ButtonP.Button;

    Button.A_button = IOC.Port60;
    Button.B_button = IOC.Port21;
    Button.C_button = IOC.Port61;
    Button.D_button = IOC.Port23;
    Button.E_button = IOC.Port62;
    Button.F_button = IOC.Port26;
}