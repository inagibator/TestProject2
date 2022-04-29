inherited K_FormCMDistr: TK_FormCMDistr
  Left = 348
  Top = 308
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'CMS Distributive Creation'
  ClientHeight = 141
  ClientWidth = 420
  DefaultMonitor = dmPrimary
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbShowInfo: TLabel [0]
    Left = 16
    Top = 24
    Width = 401
    Height = 41
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'CMS Distributive Files preparing is started'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 407
    Top = 126
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 122
    Width = 420
    Height = 19
    Panels = <>
  end
  object BtOK: TButton
    Left = 176
    Top = 88
    Width = 75
    Height = 21
    Caption = 'OK'
    Enabled = False
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object Timer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerTimer
    Left = 8
    Top = 48
  end
end
