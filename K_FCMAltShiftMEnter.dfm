inherited K_FormCMAltShiftMEnter: TK_FormCMAltShiftMEnter
  Left = 239
  Top = 490
  BorderStyle = bsSingle
  Caption = 'Advanced settings'
  ClientHeight = 116
  ClientWidth = 224
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbConfirmation: TLabel [0]
    Left = 61
    Top = 17
    Width = 151
    Height = 25
    Alignment = taCenter
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'Please enter password'
    WordWrap = True
  end
  object Image: TImage [1]
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  object LbPassword: TLabel [2]
    Left = 16
    Top = 54
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 214
    Top = 106
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 153
    Top = 88
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 80
    Top = 88
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object EdPassword: TEdit
    Left = 88
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
