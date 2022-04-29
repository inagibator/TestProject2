inherited N_EditParamsForm: TN_EditParamsForm
  Left = 267
  Top = 553
  Width = 231
  Height = 101
  Caption = 'N_EditParamsForm'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  DesignSize = (
    223
    63)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 213
    Top = 57
    TabOrder = 2
  end
  object bnOk: TButton
    Left = 97
    Top = 37
    Width = 56
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
    OnClick = bnOkClick
  end
  object bnCancel: TButton
    Left = 162
    Top = 37
    Width = 56
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    OnClick = bnCancelClick
  end
end
