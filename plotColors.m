function [] = plotColors(index,rgbM,rgbC)
%compares visually two colors of index index
singleRgbM = rgbM(1:3,index);
singleRgbC = rgbC(1:3,index);
rectangle('Position',[0 0 0.5 1],'EdgeColor',singleRgbM,'FaceColor',singleRgbM);
hold on;
rectangle('Position',[0.5 0 0.5 1],'EdgeColor',singleRgbC,'FaceColor',singleRgbC);
end

