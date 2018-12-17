/*button config*/
configuration ButtonC{
    provides interface Button;
}
implementation{
    components ButtonP;
    components HplMsp430GeneralIOC as IOC;

    Button = ButtonP.Button;

    ButtonP.A_button -> IOC.Port60;
    ButtonP.B_button -> IOC.Port21;
    ButtonP.C_button -> IOC.Port61;
    ButtonP.D_button -> IOC.Port23;
    ButtonP.E_button -> IOC.Port62;
    ButtonP.F_button -> IOC.Port26;
}