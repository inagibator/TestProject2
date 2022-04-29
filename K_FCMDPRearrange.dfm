inherited K_FormCMDPRearrange: TK_FormCMDPRearrange
  Left = 148
  Top = 223
  Width = 153
  Height = 131
  BorderIcons = [biSystemMenu]
  Caption = 'Device Profiles Rearrange'
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 125
    Top = 80
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 137
    Height = 56
    ButtonHeight = 50
    ButtonWidth = 51
    Caption = 'ToolBar1'
    Color = clActiveCaption
    ParentColor = False
    TabOrder = 1
    Wrapable = False
    OnDragOver = ToolBar1DragOver
  end
  object BtOK: TButton
    Left = 6
    Top = 63
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 70
    Top = 63
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object DragTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = DragTimerTimer
    Left = 8
    Top = 32
  end
end
