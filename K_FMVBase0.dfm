inherited K_FormMVBase0: TK_FormMVBase0
  Left = 288
  Top = 220
  Width = 311
  Height = 59
  Caption = 'K_FormMVBase0'
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  DesignSize = (
    303
    25)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 289
    Top = 11
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 303
    Height = 25
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      303
      25)
    object BtApply: TButton
      Left = 86
      Top = 3
      Width = 76
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = BtApplyClick
    end
    object BtCancel: TButton
      Left = 246
      Top = 3
      Width = 56
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = #1054#1090#1082#1072#1079
      ModalResult = 2
      TabOrder = 1
      OnClick = BtCancelClick
    end
    object BtOK: TButton
      Left = 182
      Top = 3
      Width = 56
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = #1054#1050
      ModalResult = 1
      TabOrder = 2
      OnClick = BtOKClick
    end
  end
end
