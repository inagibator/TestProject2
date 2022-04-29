inherited K_FormCMImportReverseEnter: TK_FormCMImportReverseEnter
  Left = 362
  Top = 319
  BorderStyle = bsSingle
  Caption = 'Advanced settings'
  ClientHeight = 140
  ClientWidth = 245
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbConfirmation: TLabel [0]
    Left = 58
    Top = 17
    Width = 180
    Height = 25
    Alignment = taCenter
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'Please enter name and password'
    WordWrap = True
  end
  object LbUserName: TLabel [1]
    Left = 16
    Top = 54
    Width = 54
    Height = 13
    Caption = 'User name:'
  end
  object Image: TImage [2]
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  object LbPassword: TLabel [3]
    Left = 16
    Top = 82
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 235
    Top = 130
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 173
    Top = 112
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 96
    Top = 112
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object EdUserName: TEdit
    Left = 88
    Top = 52
    Width = 129
    Height = 21
    Color = 10682367
    TabOrder = 2
    OnKeyDown = EdUserNameKeyDown
  end
  object EdPassword: TEdit
    Left = 88
    Top = 80
    Width = 129
    Height = 21
    Color = 10682367
    PasswordChar = '*'
    TabOrder = 3
    Text = '******************************'
    OnKeyDown = EdPasswordKeyDown
  end
end
