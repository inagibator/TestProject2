inherited N_CMSharp1Form: TN_CMSharp1Form
  Left = 219
  Top = 534
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = '  Sharp / Smooth'
  ClientHeight = 130
  ClientWidth = 313
  PixelsPerInch = 96
  TextHeight = 13
  object LbSharpen: TLabel [0]
    Left = 20
    Top = 6
    Width = 28
    Height = 13
    Caption = 'Sharp'
  end
  object LbSmoothen: TLabel [1]
    Left = 254
    Top = 6
    Width = 36
    Height = 13
    Caption = 'Smooth'
  end
  object Label1: TLabel [2]
    Left = 10
    Top = 50
    Width = 29
    Height = 13
    Caption = '-100%'
  end
  object Label2: TLabel [3]
    Left = 276
    Top = 50
    Width = 26
    Height = 13
    Caption = '100%'
  end
  object Label3: TLabel [4]
    Left = 151
    Top = 50
    Width = 6
    Height = 13
    Caption = '0'
  end
  inherited BFMinBRPanel: TPanel
    Left = 303
    Top = 120
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 21
    Top = 99
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 213
    Top = 99
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object TBVal: TTrackBar
    Left = 12
    Top = 22
    Width = 286
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 100
    Max = 10000
    PageSize = 1000
    Frequency = 500
    TabOrder = 2
    ThumbLength = 16
    OnChange = TBValChange
  end
  object BtApply: TButton
    Left = 132
    Top = 99
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '&Apply'
    TabOrder = 3
    OnClick = BtApplyClick
  end
  object Edit1: TEdit
    Left = 131
    Top = 66
    Width = 49
    Height = 21
    TabOrder = 5
    Text = ' -73.1%'
  end
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Left = 224
    Top = 176
  end
end
