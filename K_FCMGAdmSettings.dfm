inherited K_FormCMGAdmSettings: TK_FormCMGAdmSettings
  Left = 610
  Top = 453
  BorderStyle = bsSingle
  Caption = 'New account settings'
  ClientHeight = 173
  ClientWidth = 297
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbConfirmation: TLabel [0]
    Left = 64
    Top = 8
    Width = 222
    Height = 44
    Alignment = taCenter
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 
      'Please enter new user name and password (4-16 symbols). Please n' +
      'ote they are case sensitive.'
    WordWrap = True
  end
  object LbUserName: TLabel [1]
    Left = 10
    Top = 57
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
    Left = 10
    Top = 85
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  object LbPassword1: TLabel [4]
    Left = 10
    Top = 115
    Width = 87
    Height = 13
    Caption = 'Repeat Password:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 287
    Top = 163
    TabOrder = 5
  end
  object BtCancel: TButton
    Left = 225
    Top = 145
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 148
    Top = 145
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object EdUserName: TEdit
    Left = 106
    Top = 55
    Width = 185
    Height = 21
    Color = 10682367
    MaxLength = 16
    TabOrder = 2
    OnKeyDown = EdUserNameKeyDown
  end
  object EdPassword: TEdit
    Left = 106
    Top = 83
    Width = 185
    Height = 21
    Color = 10682367
    MaxLength = 16
    PasswordChar = '#'
    TabOrder = 3
    Text = '****************'
    OnKeyDown = EdPasswordKeyDown
  end
  object EdPassword1: TEdit
    Left = 106
    Top = 113
    Width = 185
    Height = 21
    Color = 10682367
    MaxLength = 15
    PasswordChar = '#'
    TabOrder = 4
    Text = '****************'
    OnKeyDown = EdPassword1KeyDown
  end
end
