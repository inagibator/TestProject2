object N_BrigHistFrame: TN_BrigHistFrame
  Left = 0
  Top = 0
  Width = 255
  Height = 86
  TabOrder = 0
  inline RFrame: TN_Rast1Frame
    Left = 0
    Top = 0
    Width = 255
    Height = 86
    HelpType = htKeyword
    Align = alClient
    Constraints.MinHeight = 56
    Constraints.MinWidth = 56
    Color = clBtnFace
    ParentColor = False
    TabOrder = 0
    inherited PaintBox: TPaintBox
      Width = 239
      Height = 70
    end
    inherited HScrollBar: TScrollBar
      Top = 70
      Width = 255
    end
    inherited VScrollBar: TScrollBar
      Left = 239
      Height = 70
    end
  end
end
