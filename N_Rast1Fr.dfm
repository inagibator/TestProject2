object N_Rast1Frame: TN_Rast1Frame
  Left = 0
  Top = 0
  Width = 131
  Height = 56
  HelpType = htKeyword
  Constraints.MinHeight = 56
  Constraints.MinWidth = 56
  Color = clBtnFace
  ParentColor = False
  TabOrder = 0
  OnMouseWheel = FrameMouseWheel
  OnResize = OnResizeFrame
  object PaintBox: TPaintBox
    Left = 0
    Top = 0
    Width = 115
    Height = 40
    Align = alClient
    Constraints.MinHeight = 40
    Constraints.MinWidth = 40
    OnDblClick = PaintBoxDblClick
    OnMouseDown = PaintBoxMouseDown
    OnMouseMove = PaintBoxMouseMove
    OnMouseUp = PaintBoxMouseUp
    OnPaint = PBPaint
  end
  object HScrollBar: TScrollBar
    Left = 0
    Top = 40
    Width = 131
    Height = 16
    Align = alBottom
    Max = 10000
    PageSize = 0
    TabOrder = 0
    Visible = False
    OnChange = HVScrollBarChange
  end
  object VScrollBar: TScrollBar
    Left = 115
    Top = 0
    Width = 16
    Height = 40
    Align = alRight
    Kind = sbVertical
    Max = 10000
    PageSize = 0
    TabOrder = 1
    Visible = False
    OnChange = HVScrollBarChange
  end
  object RFrame1ActionList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 40
    Top = 8
    object aShowOptionsForm: TAction
      Caption = 'Options  ...'
      Hint = 'View and Edit Options'
      ImageIndex = 19
      OnExecute = aShowOptionsFormExecute
    end
    object aInitFrame: TAction
      Caption = 'View Full Image'
      Hint = 'View Full Image and Adjust Form Size'
      ImageIndex = 52
      OnExecute = aInitFrameExecute
    end
    object aRedrawFrame: TAction
      Caption = 'Redraw'
      Hint = 'Redraw'
      ImageIndex = 38
      OnExecute = aRedrawFrameExecute
    end
    object aShowCompBorders: TAction
      Caption = 'Show Componets Borders'
      Hint = 'Show Componets Borders'
      ImageIndex = 55
      OnExecute = aShowCompBordersExecute
    end
    object aFitInWindow: TAction
      Caption = 'Fit To Window'
      Hint = 'Fit To Window'
      ImageIndex = 212
      OnExecute = aFitInWindowExecute
    end
    object aFitInCompSize: TAction
      Caption = 'View 1:1'
      Hint = 'View 1:1'
      ImageIndex = 222
      OnExecute = aFitInCompSizeExecute
    end
    object aCopyToClipboard: TAction
      Caption = 'Copy To Clipboard'
      Hint = 'Copy To Clipboard'
      ImageIndex = 12
      OnExecute = aCopyToClipboardExecute
    end
    object aZoomIn: TAction
      Caption = 'Zoom In'
      Hint = 'Zoom In'
      ImageIndex = 63
      OnExecute = aZoomInExecute
    end
    object aZoomOut: TAction
      Caption = 'Zoom Out'
      Hint = 'Zoom Out'
      ImageIndex = 62
      OnExecute = aZoomOutExecute
    end
    object aFullScreen: TAction
      Caption = 'View on Full Screen'
      Hint = 'View on Full Screen'
      ImageIndex = 238
      OnExecute = aFullScreenExecute
    end
  end
  object RepeatMouseDown: TTimer
    Enabled = False
    Interval = 0
    OnTimer = CallMouseDown
    Left = 8
    Top = 8
  end
end
