inherited K_FormCMProfileSetting: TK_FormCMProfileSetting
  Left = 282
  Top = 319
  BorderStyle = bsSingle
  Caption = 'Capture Device Setting'
  ClientHeight = 380
  ClientWidth = 261
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object IconImage: TImage [0]
    Left = 20
    Top = 12
    Width = 44
    Height = 44
  end
  object LbProfileName: TLabel [1]
    Left = 80
    Top = 26
    Width = 168
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'LbProfileName'
    WordWrap = True
  end
  inherited BFMinBRPanel: TPanel
    Left = 251
    Top = 370
    TabOrder = 8
  end
  object BtCancel: TButton
    Left = 183
    Top = 350
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 106
    Top = 350
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object BtApply: TButton
    Left = 18
    Top = 350
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '&Apply'
    TabOrder = 2
    OnClick = BtApplyClick
  end
  object RGResType: TRadioGroup
    Left = 16
    Top = 64
    Width = 231
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Select known Device parameter  '
    Ctl3D = True
    Items.Strings = (
      'pixel size, '#181'm'
      'pixels per mm'
      'dpi')
    ParentCtl3D = False
    TabOrder = 3
    OnClick = RGResTypeClick
  end
  object EdMicron: TEdit
    Left = 184
    Top = 80
    Width = 49
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    MaxLength = 5
    TabOrder = 4
    OnExit = EdMicronExit
    OnKeyDown = EdMicronKeyDown
  end
  object EdPixCM: TEdit
    Left = 184
    Top = 109
    Width = 49
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    MaxLength = 4
    TabOrder = 5
    OnExit = EdMicronExit
    OnKeyDown = EdMicronKeyDown
  end
  object EdDPI: TEdit
    Left = 184
    Top = 138
    Width = 49
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    MaxLength = 4
    TabOrder = 6
    OnExit = EdMicronExit
    OnKeyDown = EdMicronKeyDown
  end
  object ChBSkipDevRes: TCheckBox
    Left = 16
    Top = 176
    Width = 297
    Height = 17
    Caption = 'Ignore device resolution'
    TabOrder = 7
    OnClick = ChBSkipDevResClick
  end
  object GBDICOM: TGroupBox
    Left = 16
    Top = 200
    Width = 231
    Height = 137
    Anchors = [akLeft, akTop, akRight]
    Caption = '  X-Ray Device parameters  '
    TabOrder = 9
    DesignSize = (
      231
      137)
    object LbVolt: TLabel
      Left = 8
      Top = 20
      Width = 55
      Height = 13
      Caption = 'Voltage, kV'
    end
    object LbCur: TLabel
      Left = 8
      Top = 49
      Width = 55
      Height = 13
      Caption = 'Current, mA'
    end
    object LbExpTime: TLabel
      Left = 8
      Top = 78
      Width = 63
      Height = 13
      Caption = 'Exposure, ms'
    end
    object LbMod: TLabel
      Left = 8
      Top = 107
      Width = 77
      Height = 13
      Caption = 'DICOM Modality'
    end
    object EdVoltage: TEdit
      Left = 168
      Top = 16
      Width = 49
      Height = 21
      Anchors = [akTop, akRight]
      Color = 10682367
      TabOrder = 0
      OnChange = EdVoltageChange
    end
    object EdCurrent: TEdit
      Left = 168
      Top = 45
      Width = 49
      Height = 21
      Anchors = [akTop, akRight]
      Color = 10682367
      TabOrder = 1
      OnChange = EdVoltageChange
    end
    object EdExpTime: TEdit
      Left = 168
      Top = 74
      Width = 49
      Height = 21
      Anchors = [akTop, akRight]
      Color = 10682367
      TabOrder = 2
      OnChange = EdVoltageChange
    end
    object CmBModality: TComboBox
      Left = 168
      Top = 103
      Width = 49
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      Color = 10682367
      ItemHeight = 13
      TabOrder = 3
      OnChange = CmBModalityChange
    end
  end
end
