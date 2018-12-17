/*button config*/
configuration ButtonC{
    provides interface Button;
}
implementation{
    components ButtonP;
    components HplMsp430GeneralIOC;

    Button = ButtonP.Button;

    ButtonP.A_button -> HplMsp430GeneralIOC.Port60;
    ButtonP.B_button -> HplMsp430GeneralIOC.Port21;
    ButtonP.C_button -> HplMsp430GeneralIOC.Port61;
    ButtonP.D_button -> HplMsp430GeneralIOC.Port23;
    ButtonP.E_button -> HplMsp430GeneralIOC.Port62;
    ButtonP.F_button -> HplMsp430GeneralIOC.Port26;
}