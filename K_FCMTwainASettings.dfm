inherited K_FormCMTwainASettings: TK_FormCMTwainASettings
  Left = 366
  Top = 168
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Advanced settings '
  ClientHeight = 337
  ClientWidth = 231
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 219
    Top = 325
  end
  object RGDataTransferMode: TRadioGroup
    Left = 8
    Top = 112
    Width = 217
    Height = 75
    Caption = '  Twain Data Transfer Mode  '
    ItemIndex = 0
    Items.Strings = (
      'native'
      'disk file'
      'memory buffer')
    TabOrder = 1
  end
  object RGCMSMode: TRadioGroup
    Left = 8
    Top = 196
    Width = 217
    Height = 100
    Caption = '  Media Suite Events Recieve Method  '
    ItemIndex = 0
    Items.Strings = (
      'Events method 1'
      'Events method 2'
      'Events method 3'
      'Events method 4')
    TabOrder = 2
  end
  object RGGeneralMode: TRadioGroup
    Left = 8
    Top = 4
    Width = 217
    Height = 100
    Caption = '  General Twain Capture Mode  '
    ItemIndex = 0
    Items.Strings = (
      'Mode 1'
      'Mode 2 '
      'Mode 3'
      'Mode 4')
    TabOrder = 3
    OnClick = RGGeneralModeClick
  end
  object BtOK: TButton
    Left = 80
    Top = 306
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 159
    Top = 306
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 5
  end
end
