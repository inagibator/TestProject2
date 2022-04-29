inherited N_CMCaptDev26aForm: TN_CMCaptDev26aForm
  Left = 160
  Top = 627
  Caption = 'Morita'
  ClientHeight = 83
  ClientWidth = 192
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 208
  ExplicitHeight = 122
  DesignSize = (
    192
    83)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 206
    Top = 64
    ExplicitLeft = 206
    ExplicitTop = 64
  end
  object bnOK: TButton
    Left = 133
    Top = 40
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  object cb8bit: TCheckBox
    Left = 16
    Top = 16
    Width = 97
    Height = 17
    Caption = '8 bit'
    TabOrder = 2
  end
end
