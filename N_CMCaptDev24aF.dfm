inherited N_CMCaptDev24aForm: TN_CMCaptDev24aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'N_CMCaptDev24aForm'
  ClientHeight = 68
  ClientWidth = 211
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 227
  ExplicitHeight = 107
  DesignSize = (
    211
    68)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 217
    Top = 67
    ExplicitLeft = 217
    ExplicitTop = 67
  end
  object bnOK: TButton
    Left = 144
    Top = 43
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  object chb16BitMode: TCheckBox
    Left = 24
    Top = 16
    Width = 97
    Height = 17
    Caption = '16 Bit Mode'
    TabOrder = 2
  end
end
