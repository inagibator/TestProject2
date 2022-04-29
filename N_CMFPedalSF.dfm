inherited N_CMFPedalSetupForm: TN_CMFPedalSetupForm
  Left = 338
  Top = 673
  BorderStyle = bsDialog
  Caption = 'Foot Pedal Setup'
  ClientHeight = 154
  ClientWidth = 290
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  ExplicitWidth = 320
  ExplicitHeight = 240
  DesignSize = (
    290
    154)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 27
    Width = 34
    Height = 13
    Caption = 'Device'
  end
  inherited BFMinBRPanel: TPanel
    Left = 280
    Top = 145
    TabOrder = 3
    ExplicitLeft = 280
    ExplicitTop = 145
  end
  object bnCancel: TButton
    Left = 200
    Top = 119
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object bnOK: TButton
    Left = 114
    Top = 119
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object cbFootPedals: TComboBox
    Left = 56
    Top = 24
    Width = 225
    Height = 21
    TabOrder = 2
    Text = 'cbFootPedals'
    OnCloseUp = cbFootPedalsCloseUp
  end
  object cbReverseLR: TCheckBox
    Left = 57
    Top = 57
    Width = 129
    Height = 17
    Caption = '_Reverse Left/Right'
    TabOrder = 4
  end
  object edComPortNum: TLabeledEdit
    Left = 189
    Top = 81
    Width = 36
    Height = 21
    EditLabel.Width = 129
    EditLabel.Height = 13
    EditLabel.Caption = 'COM Port number (1-127)   '
    LabelPosition = lpLeft
    TabOrder = 5
  end
end
