inherited N_CMCaptDev22aForm: TN_CMCaptDev22aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'N_CMCaptDev22aForm'
  ClientHeight = 113
  ClientWidth = 319
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 335
  ExplicitHeight = 152
  DesignSize = (
    319
    113)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 325
    Top = 93
    ExplicitLeft = 325
    ExplicitTop = 93
  end
  object bnOK: TButton
    Left = 252
    Top = 69
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  inline SrcPathNameFrame: TK_FPathNameFrame
    Tag = 161
    Left = 12
    Top = 16
    Width = 329
    Height = 27
    TabOrder = 2
    ExplicitLeft = 12
    ExplicitTop = 16
    ExplicitWidth = 329
    ExplicitHeight = 27
    DesignSize = (
      329
      27)
    inherited LbPathName: TLabel
      Top = 7
      Width = 61
      Caption = 'Sidexis Path:'
      ExplicitTop = 7
      ExplicitWidth = 61
    end
    inherited mbPathName: TComboBox
      Left = 74
      Width = 152
      ExplicitLeft = 74
      ExplicitWidth = 152
    end
    inherited bnBrowse_1: TButton
      Left = 232
      ExplicitLeft = 232
    end
  end
end
