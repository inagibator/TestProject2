inherited N_CMCaptDev5aForm: TN_CMCaptDev5aForm
  Left = 423
  Top = 499
  Caption = 'N_CMCaptDev5aForm'
  ClientHeight = 162
  ClientWidth = 322
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 338
  ExplicitHeight = 201
  DesignSize = (
    322
    162)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 336
    Top = 135
    TabOrder = 1
    ExplicitLeft = 336
    ExplicitTop = 135
  end
  object cbUseDidapiImagePreProcessing: TCheckBox
    Left = 8
    Top = 14
    Width = 273
    Height = 17
    Caption = 'Use DIDAPI Image PreProcessing'
    TabOrder = 0
  end
  object bnCancel: TButton
    Left = 244
    Top = 112
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    TabStop = False
  end
  object bnOK: TButton
    Left = 163
    Top = 112
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
    TabStop = False
    OnClick = bnOKClick
  end
  object cbUtilizeDidapiUi: TCheckBox
    Left = 8
    Top = 37
    Width = 273
    Height = 17
    Caption = 'Utilize DIDAPIUI Interface'
    TabOrder = 4
    OnClick = cbUtilizeDidapiUiClick
  end
  object cbDisableImagePreview: TCheckBox
    Left = 8
    Top = 62
    Width = 265
    Height = 17
    Caption = 'Disable Image Preview'
    TabOrder = 5
  end
end
