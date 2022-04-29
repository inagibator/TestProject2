unit K_FCMStudyTemplatesSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, StdCtrls, ActnList, N_Rast1Fr;

type
  TK_FormCMStudyTemplatesSetup = class(TN_BaseForm)
    TemplatesPanel: TPanel;
    CtrlsPanel: TPanel;
    GBTemplatesVis: TGroupBox;
    Splitter1: TSplitter;
    GBTemplatesHid: TGroupBox;
    ThumbsVisRFrame: TN_Rast1Frame;
    ThumbsHidRFrame: TN_Rast1Frame;
    ActionList: TActionList;
    aUnload: TAction;
    aPutBeforeAll: TAction;
    aPutAfterAll: TAction;
    aDelete: TAction;
    aHide: TAction;
    aLoad: TAction;
    BtTempLoad: TButton;
    BtOK: TButton;
    BtCancel: TButton;
    GBSelectedActs: TGroupBox;
    BtTempHide: TButton;
    BtTempBeforeAll: TButton;
    BtTempDelete: TButton;
    BtTempAfterAll: TButton;
    BtTempUnload: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_FormCMStudyTemplatesSetup: TK_FormCMStudyTemplatesSetup;

implementation

{$R *.dfm}

end.
