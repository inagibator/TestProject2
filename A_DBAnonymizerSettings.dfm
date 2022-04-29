object DBAnonymizerSettings: TDBAnonymizerSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Choose anonymization mode'
  ClientHeight = 73
  ClientWidth = 264
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object cbPatients: TCheckBox
    Left = 8
    Top = 8
    Width = 73
    Height = 17
    Caption = 'Patients'
    Checked = True
    State = cbChecked
    TabOrder = 0
  end
  object cbProviders: TCheckBox
    Left = 96
    Top = 8
    Width = 73
    Height = 17
    Caption = 'Providers'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object cbLocations: TCheckBox
    Left = 183
    Top = 8
    Width = 73
    Height = 17
    Caption = 'Locations'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 100
    Top = 40
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 181
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
