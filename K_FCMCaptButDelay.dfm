inherited K_FormCMCaptButDelay: TK_FormCMCaptButDelay
  Left = 636
  Top = 403
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Delay Setup'
  ClientWidth = 172
  FormStyle = fsStayOnTop
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbSec: TLabel [0]
    Left = 142
    Top = 16
    Width = 19
    Height = 13
    Caption = 'Sec'
  end
  inherited BFMinBRPanel: TPanel
    Left = 162
    Top = 66
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 96
    Top = 45
    Width = 66
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 14
    Top = 45
    Width = 64
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 1
    OnClick = BtOKClick
  end
  object LbEdCaptButDelay: TLabeledEdit
    Left = 79
    Top = 13
    Width = 40
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = 'Delay :       '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
    OnKeyDown = LbEditKeyDown
  end
  object UDCaptButDelay: TUpDown
    Left = 120
    Top = 14
    Width = 17
    Height = 21
    Anchors = [akTop, akRight]
    Min = 50
    Max = 500
    Increment = 50
    Position = 50
    TabOrder = 3
    OnClick = UDCaptButDelayClick
  end
end
