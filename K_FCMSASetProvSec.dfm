inherited K_FormCMSASetProvSecurity: TK_FormCMSASetProvSecurity
  Left = 205
  Top = 184
  Width = 229
  Height = 357
  Caption = 'Security limitations '
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 209
    Top = 311
  end
  object BtOK: TButton
    Left = 148
    Top = 286
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object BtCancel: TButton
    Left = 76
    Top = 286
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object ChBStart: TCheckBox
    Left = 16
    Top = 16
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Start Centaur Media Suite'
    TabOrder = 3
  end
  object ChBCapture: TCheckBox
    Left = 16
    Top = 40
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Capture Media Objects'
    TabOrder = 4
  end
  object ChBImport: TCheckBox
    Left = 16
    Top = 136
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Import Media Objects'
    TabOrder = 5
  end
  object ChBDuplicate: TCheckBox
    Left = 16
    Top = 64
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Duplicate Media Objects'
    TabOrder = 6
  end
  object ChBModify: TCheckBox
    Left = 16
    Top = 112
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Modify Media Objects'
    TabOrder = 7
  end
  object ChBDelete: TCheckBox
    Left = 16
    Top = 88
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Delete Media Objects'
    TabOrder = 8
  end
  object ChBExport: TCheckBox
    Left = 16
    Top = 160
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Export Media Objects'
    TabOrder = 9
  end
  object ChBPrint: TCheckBox
    Left = 16
    Top = 184
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Print Media Objects'
    TabOrder = 10
  end
  object ChBEmail: TCheckBox
    Left = 16
    Top = 208
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'E-mail Media Objects'
    TabOrder = 11
  end
  object ChBPref: TCheckBox
    Left = 16
    Top = 232
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Modify Preferences'
    TabOrder = 12
  end
  object ChBReports: TCheckBox
    Left = 16
    Top = 256
    Width = 196
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Create Reports'
    TabOrder = 13
  end
end
