inherited N_CMCaptDev32aForm: TN_CMCaptDev32aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Trios'
  ClientHeight = 206
  ClientWidth = 466
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 482
  ExplicitHeight = 245
  DesignSize = (
    466
    206)
  PixelsPerInch = 96
  TextHeight = 13
  object lbPCUser: TLabel [0]
    Left = 19
    Top = 24
    Width = 68
    Height = 13
    Caption = 'PC Username:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 480
    Top = 187
    ExplicitLeft = 480
    ExplicitTop = 187
  end
  object bnOK: TButton
    Left = 407
    Top = 163
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  object GroupBox1: TGroupBox
    Left = 19
    Top = 63
    Width = 209
    Height = 98
    Caption = 'Auto-Login Settings'
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 32
      Height = 13
      Caption = 'Login: '
    end
    object Label2: TLabel
      Left = 16
      Top = 56
      Width = 49
      Height = 13
      Caption = 'Password:'
    end
    object edLogin: TEdit
      Left = 71
      Top = 21
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object edPassword: TEdit
      Left = 71
      Top = 51
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
    end
  end
  object edUser: TEdit
    Left = 93
    Top = 21
    Width = 236
    Height = 21
    TabOrder = 3
  end
end
