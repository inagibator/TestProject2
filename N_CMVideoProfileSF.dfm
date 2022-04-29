inherited N_CMVideoProfileSForm: TN_CMVideoProfileSForm
  Left = 390
  Top = 165
  Caption = 'Video Profile Settings'
  ClientHeight = 332
  ClientWidth = 376
  Font.Name = 'MS Sans Serif'
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  ExplicitWidth = 392
  ExplicitHeight = 371
  DesignSize = (
    376
    332)
  PixelsPerInch = 96
  TextHeight = 13
  object lbRenderer: TLabel [0]
    Left = 249
    Top = 43
    Width = 77
    Height = 13
    Caption = 'Video Renderer:'
  end
  object lbFilter: TLabel [1]
    Left = 249
    Top = 89
    Width = 55
    Height = 13
    Caption = 'Video Filter:'
    Visible = False
  end
  object lbCloseBottom: TLabel [2]
    Left = 249
    Top = 106
    Width = 107
    Height = 13
    Caption = ' interface on Power off'
  end
  object GroupBox1: TGroupBox [3]
    Left = 21
    Top = 113
    Width = 213
    Height = 122
    Caption = ' Keystrokes '
    TabOrder = 5
    object rbFreezeUnfreeze: TRadioButton
      Left = 8
      Top = 24
      Width = 112
      Height = 17
      Caption = 'Freeze / Unfreeze'
      TabOrder = 0
      OnClick = rbFreezeUnfreezeClick
    end
    object rbSaveAndUnfreeze: TRadioButton
      Left = 9
      Top = 52
      Width = 111
      Height = 16
      Caption = 'Save and Unfreeze'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 1
      OnClick = rbSaveAndUnfreezeClick
    end
    object bnReset: TButton
      Left = 34
      Top = 83
      Width = 129
      Height = 25
      Caption = 'Reset  Keystroke'
      TabOrder = 2
      OnClick = bnResetClick
    end
  end
  inherited BFMinBRPanel: TPanel
    Left = 371
    Top = 320
    TabOrder = 4
    ExplicitLeft = 371
    ExplicitTop = 320
  end
  object rgVCMode: TRadioGroup
    Left = 20
    Top = 12
    Width = 213
    Height = 85
    Caption = ' Video Capturing Mode '
    Items.Strings = (
      'Mode 1'
      'Mode 2'
      'Mode 3 ')
    TabOrder = 0
    OnClick = rgVCModeClick
  end
  object bnOK: TButton
    Left = 295
    Top = 289
    Width = 75
    Height = 24
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
    OnClick = bnOKClick
  end
  object edFreezeUnfreeze: TEdit
    Left = 150
    Top = 135
    Width = 72
    Height = 21
    Enabled = False
    TabOrder = 1
    Text = 'edFreezeUnfreeze'
  end
  object edSaveAndUnfreeze: TEdit
    Left = 150
    Top = 163
    Width = 72
    Height = 21
    Enabled = False
    TabOrder = 2
    Text = 'edSaveAndUnfreeze'
  end
  object CmBStillPin: TCheckBox
    Left = 249
    Top = 20
    Width = 97
    Height = 17
    Caption = 'Still Pin'
    TabOrder = 6
  end
  object cbRenderer: TComboBox
    Left = 248
    Top = 62
    Width = 124
    Height = 21
    ItemIndex = 1
    TabOrder = 7
    Text = 'VMR9'
    Items.Strings = (
      'VMR7'
      'VMR9'
      'EVR')
  end
  object cbFilter: TComboBox
    Left = 249
    Top = 108
    Width = 123
    Height = 21
    TabOrder = 8
    Visible = False
  end
  object cbClose: TCheckBox
    Left = 249
    Top = 89
    Width = 130
    Height = 17
    Caption = 'Automatically close'
    TabOrder = 9
  end
  object gbSironaMode: TGroupBox
    Left = 21
    Top = 254
    Width = 214
    Height = 60
    Caption = ' Sirona Mode '
    TabOrder = 10
    object cbActivateMode: TCheckBox
      Left = 12
      Top = 18
      Width = 97
      Height = 17
      Caption = 'Activate Mode'
      TabOrder = 0
    end
    object cbCloseMode: TCheckBox
      Left = 12
      Top = 37
      Width = 97
      Height = 17
      Caption = 'Close Mode'
      TabOrder = 1
    end
  end
end
