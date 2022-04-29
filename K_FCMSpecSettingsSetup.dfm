inherited K_FormCMSpecSettings: TK_FormCMSpecSettings
  Left = 35
  Top = 302
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Special Settings'
  ClientHeight = 85
  ClientWidth = 285
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 273
    Top = 73
  end
  object BtCancel: TButton
    Left = 212
    Top = 52
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 133
    Top = 52
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 2
  end
  object ChBDICOM1: TCheckBox
    Left = 16
    Top = 16
    Width = 257
    Height = 17
    Caption = 'menu option DICOM is visible'
    TabOrder = 3
  end
end
