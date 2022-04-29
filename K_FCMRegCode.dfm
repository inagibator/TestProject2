inherited K_FormCMRegCode: TK_FormCMRegCode
  Left = 256
  Top = 378
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'DB Registration Code'
  ClientWidth = 303
  FormStyle = fsStayOnTop
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 293
    Top = 71
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 219
    Top = 50
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 137
    Top = 50
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 1
    OnClick = BtOKClick
  end
  object LbEdDBRegCode: TLabeledEdit
    Left = 129
    Top = 13
    Width = 164
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 118
    EditLabel.Height = 13
    EditLabel.Caption = 'Enter Registration Code: '
    LabelPosition = lpLeft
    TabOrder = 2
    Text = '12345678901234567890123456'
    OnKeyDown = LbEditKeyDown
  end
end
