unit N_CML2F;
// CMS GUI multilingual support - Capt devices related (#2 Interface Texts Container)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type TN_CML2Form = class( TForm )
    PageControl1: TPageControl;
    TWAIN: TTabSheet;
    LLLErrorLoading1: TLabel;
    Other: TTabSheet;
    Video: TTabSheet;
    Pedal: TTabSheet;
    LLLWrongPortNum: TLabel;
    LLLCOMPortError1: TLabel;
    LLLReverseLR: TLabel;
    LLLReverseAB: TLabel;
    LLLVideoNumCaptured: TLabel;
    LLLNotPluggedIn1: TLabel;
    LLLDirectShowError1: TLabel;
    LLLOtherFormCaption: TLabel;
    LLLOther3Disconnected: TLabel;
    LLLOther3Ready: TLabel;
    LLLOther3Scanning: TLabel;
    LLLOther3Error: TLabel;
    LLLOther3Closing: TLabel;
    LLLOther4Processing: TLabel;
    LLLOther4Ready: TLabel;
    LLLVideoSaving: TLabel;
    LLLVideoSeconds: TLabel;
    LLLVideoNotPluggedIn: TLabel;
    tsFPBNames: TTabSheet;
    tsOther: TTabSheet;
    lbComment: TLabel;
    LLLNone: TLabel;
    LLLKeyboardF5F6: TLabel;
    LLLKeyboardF7F8: TLabel;
    LLLDelcomfootpedal: TLabel;
    LLLSerialFootPedal: TLabel;
    LLLVirtualDevice1: TLabel;
    LLLVirtualDevice2: TLabel;
    LLLSoproTouch: TLabel;
    LLLSchickUSBCam2: TLabel;
    LLLWin100D: TLabel;
    LLLWin100DBDA: TLabel;
    LLLUSBPedal: TLabel;
    LLLVideoModeCaption: TLabel;
    LLLVideoModeName1: TLabel;
    LLLVideoModeName2: TLabel;
    LLLVideoModeName3: TLabel;
    LLLSchickUSBCam4: TLabel;
    LLLMultiCam: TLabel;
    LLLDUPCS: TLabel;
    LLLKeystrokes: TLabel;
    LLLQI: TLabel;
    LLLDUSirona: TLabel;
    LLLMediaCamPlus: TLabel;
end; // type TN_CML1Form = class( TForm )

var
  N_CML2Form: TN_CML2Form;

implementation

{$R *.dfm}

end.
