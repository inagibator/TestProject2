inherited K_FormCMRemoteClientSetup: TK_FormCMRemoteClientSetup
  Left = 52
  Top = 327
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '   Remote Client Setup'
  ClientHeight = 134
  ClientWidth = 372
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 362
    Top = 124
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 289
    Top = 103
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 199
    Top = 103
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object GBDeviceContext: TGroupBox
    Left = 8
    Top = 16
    Width = 356
    Height = 73
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Save device profiles in context specific to:  '
    TabOrder = 3
    object RBGAServer: TRadioButton
      Left = 124
      Top = 25
      Width = 131
      Height = 17
      Caption = 'Application Server'
      TabOrder = 0
      OnClick = RBGAServerClick
    end
    object RBClientName: TRadioButton
      Left = 68
      Top = 47
      Width = 117
      Height = 17
      Caption = 'Client Name'
      TabOrder = 1
      OnClick = RBGAServerClick
    end
    object RBGALocation: TRadioButton
      Left = 261
      Top = 25
      Width = 92
      Height = 17
      Caption = 'Location'
      TabOrder = 2
      OnClick = RBGAServerClick
    end
    object RBServer: TRadioButton
      Left = 11
      Top = 24
      Width = 107
      Height = 17
      Caption = 'No change'
      TabOrder = 3
      OnClick = RBGAServerClick
    end
    object RBClientIP: TRadioButton
      Left = 191
      Top = 48
      Width = 142
      Height = 17
      Caption = 'Client IP Address'
      TabOrder = 4
      OnClick = RBGAServerClick
    end
  end
end
