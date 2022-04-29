inherited K_FormCMEnterDBAPSW: TK_FormCMEnterDBAPSW
  Left = 610
  Top = 453
  BorderStyle = bsSingle
  Caption = 'DBA password'
  ClientHeight = 151
  ClientWidth = 225
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbConfirmation: TLabel [0]
    Left = 52
    Top = 8
    Width = 161
    Height = 41
    Alignment = taCenter
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 
      'Please enter DBA password (1-16 symbols). Please note they are c' +
      'ase sensitive.'
    WordWrap = True
  end
  object Image: TImage [1]
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  object LbPassword: TLabel [2]
    Left = 10
    Top = 61
    Width = 73
    Height = 13
    Caption = 'DBA password:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 215
    Top = 141
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 150
    Top = 123
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 76
    Top = 123
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object EdPassword: TEdit
    Left = 95
    Top = 59
    Width = 121
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    MaxLength = 16
    PasswordChar = '#'
    TabOrder = 2
    Text = '****************'
    OnKeyDown = EdPasswordKeyDown
  end
  object ChBViewPSW: TCheckBox
    Left = 16
    Top = 96
    Width = 201
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'View password'
    TabOrder = 4
    OnClick = ChBViewPSWClick
  end
end
