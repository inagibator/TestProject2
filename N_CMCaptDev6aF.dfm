inherited N_CMCaptDev6aForm: TN_CMCaptDev6aForm
  Left = 139
  Top = 22
  Width = 357
  Height = 279
  Caption = 'N_CMCaptDev6aForm'
  OldCreateOrder = True
  DesignSize = (
    341
    240)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 16
    Top = 8
    Width = 72
    Height = 13
    Caption = 'Device mode : '
  end
  inherited BFMinBRPanel: TPanel
    Left = 355
    Top = 187
    TabOrder = 2
  end
  object cbDeviceMode: TComboBox
    Left = 16
    Top = 27
    Width = 273
    Height = 21
    DropDownCount = 30
    ItemHeight = 13
    TabOrder = 0
  end
  object cbCloseonexit: TCheckBox
    Left = 16
    Top = 54
    Width = 273
    Height = 17
    Caption = 'Close Vista Easy after scan'
    TabOrder = 1
  end
  object bnCancel: TButton
    Left = 175
    Top = 163
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    TabStop = False
  end
  object bnOK: TButton
    Left = 256
    Top = 163
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 4
    TabStop = False
    OnClick = bnOKClick
  end
  object cbAutoclosePrescan: TCheckBox
    Left = 16
    Top = 77
    Width = 273
    Height = 17
    Caption = 'Autoclose the Prescan interface'
    TabOrder = 5
  end
  object cbActivateView: TCheckBox
    Left = 16
    Top = 102
    Width = 265
    Height = 17
    Caption = 'Activate Vista Easy View'
    TabOrder = 6
  end
  object cbDonotDisplayPatinfo: TCheckBox
    Left = 16
    Top = 124
    Width = 273
    Height = 19
    Caption = 'Do not display patient details on a scanner'
    TabOrder = 7
  end
end
