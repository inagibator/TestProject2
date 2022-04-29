unit N_CML1F;
// CMS GUI multilingual support - #1 Interface Texts Container

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type TN_CML1Form = class( TForm )
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    LLLNotEnoughMem1: TLabel;
end; // type TN_CML1Form = class( TForm )

var
  N_CML1Form: TN_CML1Form;

implementation

{$R *.dfm}

end.
