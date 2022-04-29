inherited K_FormCMSetSlidesAttrs3: TK_FormCMSetSlidesAttrs3
  Left = 450
  Top = 205
  Width = 796
  PixelsPerInch = 96
  TextHeight = 13
  inherited LbMediaType: TLabel
    Left = 11
  end
  object LbStudyNote: TLabel [3]
    Left = 184
    Top = 10
    Width = 600
    Height = 13
    Alignment = taCenter
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'Select the position on the Template to Process the Image'
  end
  inherited BFMinBRPanel: TPanel
    Left = 769
    Top = 551
  end
  inherited BtResetChart: TButton
    Left = 428
    Visible = False
  end
  inherited MemoDiagnoses: TMemo
    Width = 169
  end
  inherited Button1: TButton
    Left = 404
  end
  inherited Button2: TButton
    Left = 701
  end
  inherited CmBMediaTypes: TComboBox
    Width = 171
  end
  inherited ThumbPanel: TPanel
    Width = 773
    inherited ThumbsRFrame: TN_Rast1Frame
      Width = 771
      inherited PaintBox: TPaintBox
        Width = 755
      end
      inherited HScrollBar: TScrollBar
        Width = 771
      end
      inherited VScrollBar: TScrollBar
        Left = 755
      end
    end
  end
  inherited Button3: TButton
    Left = 589
  end
  inherited Button4: TButton
    Left = 476
  end
  inherited Button5: TButton
    Left = 332
  end
  inherited CMSTeethChartFrame: TK_FrameCMTeethChart1
    Left = 187
    Width = 590
    Visible = False
    inherited Image1: TImage
      Width = 590
      Anchors = [akLeft, akTop, akBottom]
    end
  end
  inline CMStudyFrame: TN_CMREdit3Frame [24]
    Left = 177
    Top = 28
    Width = 597
    Height = 334
    Anchors = [akLeft, akTop, akRight]
    Constraints.MinHeight = 80
    Constraints.MinWidth = 70
    Color = clBtnShadow
    ParentBackground = False
    ParentColor = False
    TabOrder = 16
    inherited FrameRightCaption: TLabel
      Left = 477
    end
    inherited FinishEditing: TSpeedButton
      Left = 576
    end
    inherited RFrame: TN_MapEdFrame
      Left = 0
      Top = 0
      Width = 597
      Height = 334
      Align = alClient
      inherited PaintBox: TPaintBox
        Width = 581
        Height = 318
        OnMouseDown = CMStudyFrameMouseDown
        OnMouseUp = CMStudyFrameMouseUp
      end
      inherited HScrollBar: TScrollBar
        Top = 318
        Width = 597
      end
      inherited VScrollBar: TScrollBar
        Left = 581
        Height = 318
      end
    end
  end
  inherited ChBAutoOpen: TCheckBox [25]
    TabOrder = 17
  end
  inherited EdVoltage: TEdit [26]
    TabOrder = 18
  end
  inherited EdCurrent: TEdit [27]
    TabOrder = 19
  end
  inherited EdExpTime: TEdit [28]
    TabOrder = 20
  end
  inherited CmBModality: TComboBox [29]
    TabOrder = 21
  end
end
