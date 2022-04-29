inherited K_FormCMSZoomMode: TK_FormCMSZoomMode
  Left = 488
  Top = 332
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = ' Zoom'
  ClientHeight = 377
  ClientWidth = 120
  DefaultMonitor = dmDesktop
  FormStyle = fsStayOnTop
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Lb100_: TLabel [0]
    Left = 33
    Top = 327
    Width = 13
    Height = 13
    Caption = '1X'
  end
  object Lb800_: TLabel [1]
    Left = 33
    Top = 4
    Width = 13
    Height = 13
    Caption = '8X'
  end
  object Lb200_: TLabel [2]
    Left = 33
    Top = 280
    Width = 13
    Height = 13
    Caption = '2X'
  end
  object Lb700_: TLabel [3]
    Left = 33
    Top = 50
    Width = 26
    Height = 13
    Caption = '700%'
    Visible = False
    WordWrap = True
  end
  object Lb300_: TLabel [4]
    Left = 33
    Top = 234
    Width = 26
    Height = 13
    Caption = '300%'
    Visible = False
  end
  object Lb400_: TLabel [5]
    Left = 33
    Top = 188
    Width = 13
    Height = 13
    Caption = '4X'
  end
  object Lb500_: TLabel [6]
    Left = 33
    Top = 142
    Width = 26
    Height = 13
    Caption = '500%'
    Visible = False
    WordWrap = True
  end
  object Lb600_: TLabel [7]
    Left = 33
    Top = 96
    Width = 26
    Height = 13
    Caption = '600%'
    Visible = False
    WordWrap = True
  end
  object ZoomTrackBar: TTrackBar [8]
    Left = 0
    Top = 0
    Width = 30
    Height = 377
    Anchors = [akLeft, akTop, akBottom]
    BorderWidth = 1
    Max = 800
    Min = 30
    Orientation = trVertical
    ParentShowHint = False
    Frequency = 10
    Position = 100
    ShowHint = True
    TabOrder = 1
    ThumbLength = 18
    OnChange = ZoomTrackBarChange
  end
  inherited BFMinBRPanel: TPanel
    Left = 44
    Top = 365
  end
end
