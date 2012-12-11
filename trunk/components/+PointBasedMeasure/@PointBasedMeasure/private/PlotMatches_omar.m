function PlotMatches_omar(im1,im2,match)
        figure(1);
        figure('Name','Image Pair','NumberTitle','off');
        clf;
        subplot(1,2,1);  
        hold on;      
        colormap('gray');
        imshow(im1);
        plot(match(:,1),match(:,2), 'o');
        hold off;
    
        % plot the matches on the second image        
        subplot(1,2,2);
        hold on;
        colormap('gray');
        imshow(im2);
        plot(match(:,3),match(:,4), 'o');
        hold off;
 
%         % plot the matches of the the two images
%         figure(3);
%         clf;
%         colormap('gray');
%         im3 = mean([im1(:,:) im2(:,:)]);
%         imagesc(im3);
%         hold on;
%         for ind = 1: size(match,1)
%             line([match(ind,1) match(ind,3)], [match(ind,2) match(ind,4)], 'Color', 'c');
%         end
%         hold off;
end