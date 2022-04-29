inherited N_CMCaptDev18aForm: TN_CMCaptDev18aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'N_CMCaptDev18aForm'
  ClientHeight = 161
  ClientWidth = 302
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 318
  ExplicitHeight = 200
  DesignSize = (
    302
    161)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 322
    Top = 146
    ExplicitLeft = 322
    ExplicitTop = 146
  end
  object bnOK: TButton
    Left = 249
    Top = 120
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  object RadioGroup1: TRadioGroup
    Left = 24
    Top = 16
    Width = 249
    Height = 73
    Caption = 'Mode'
    ItemIndex = 0
    Items.Strings = (
      '1 or Normal: Showing Capture Image Preview'
      '2 or Template: not Showing Captured Images')
    TabOrder = 2
    OnClick = RadioGroup1Click
  end
end
