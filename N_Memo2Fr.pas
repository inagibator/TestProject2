unit N_Memo2Fr;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  N_Types; 

type
  TN_Memo2Frame = class(TFrame)
    Memo: TMemo;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

end.
