inherited N_CMCaptDev5dForm: TN_CMCaptDev5dForm
  Left = 160
  Top = 627
  Caption = 'N_CMCaptDev5dForm'
  ClientHeight = 364
  ClientWidth = 496
  ExplicitWidth = 512
  ExplicitHeight = 403
  DesignSize = (
    496
    364)
  PixelsPerInch = 96
  TextHeight = 13
  object lbNote: TLabel [0]
    Left = 8
    Top = 13
    Width = 299
    Height = 13
    Caption = 'There are some devices of this type. Please select one of them:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 502
    Top = 329
    ExplicitLeft = 502
    ExplicitTop = 329
  end
  object bnCancel: TButton
    Left = 322
    Top = 291
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    TabStop = False
  end
  object bnOK: TButton
    Left = 403
    Top = 291
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
    TabStop = False
    OnClick = bnOKClick
  end
  object lbDevices: TListBox
    Left = 8
    Top = 32
    Width = 457
    Height = 241
    Color = clInfoBk
    ItemHeight = 13
    TabOrder = 3
  end
end
