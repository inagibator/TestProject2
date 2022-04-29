inherited K_FormCMDeviceSetupEnter: TK_FormCMDeviceSetupEnter
  Left = 167
  Top = 200
  BorderStyle = bsSingle
  Caption = 'Capture setup confirmation'
  ClientHeight = 116
  ClientWidth = 258
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbConfirmation: TLabel [0]
    Left = 48
    Top = 8
    Width = 203
    Height = 25
    Alignment = taCenter
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'This area is for advanced users only.'
    WordWrap = True
  end
  object LbPassword: TLabel [1]
    Left = 40
    Top = 54
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Image: TImage [2]
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  inherited BFMinBRPanel: TPanel
    Left = 248
    Top = 106
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 186
    Top = 88
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 109
    Top = 88
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object EdPassword: TEdit
    Left = 120
    Top = 52
    Width = 129
    Height = 21
    Color = 10682367
    PasswordChar = '*'
    TabOrder = 2
    Text = '******************************'
    OnKeyDown = EdPasswordKeyDown
  end
end
