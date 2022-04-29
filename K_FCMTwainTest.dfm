inherited K_FormCMTwainTest: TK_FormCMTwainTest
  Left = 229
  Top = 188
  Width = 342
  Height = 228
  Caption = 'MediaSiute TWAIN'
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 11
    Width = 42
    Height = 13
    Caption = 'Devices:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 314
    Top = 177
  end
  object CmBDevices: TComboBox
    Left = 56
    Top = 8
    Width = 233
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnChange = CmBDevicesChange
  end
  object RGDataTransferMode: TRadioGroup
    Left = 8
    Top = 48
    Width = 129
    Height = 75
    Caption = '  Data Transfer Mode  '
    Items.Strings = (
      'native'
      'disk file'
      'memory buffer')
    TabOrder = 2
    OnClick = RGDataTransferModeClick
  end
  object RGCMSMode: TRadioGroup
    Left = 152
    Top = 48
    Width = 137
    Height = 57
    Caption = '  Events Transfer Mode  '
    ItemIndex = 1
    Items.Strings = (
      'Mode 1'
      'Mode 2')
    TabOrder = 3
  end
  object BtRun: TButton
    Left = 88
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Run device'
    TabOrder = 4
    OnClick = BtRunClick
  end
  object BtClose: TButton
    Left = 198
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Close'
    ModalResult = 1
    TabOrder = 5
    OnClick = BtCloseClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 170
    Width = 326
    Height = 19
    Panels = <>
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 16
    Top = 136
  end
end
