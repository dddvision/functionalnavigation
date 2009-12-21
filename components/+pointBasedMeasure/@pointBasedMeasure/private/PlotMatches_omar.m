function PlotMatches_omar(im1,im2,match)
figure(1);
        clf;
        colormap('gray');
        imshow(im1);
        hold on;
        for ind = 1: size(match,1)
            plot(match(ind,1),match(ind,2), 'o');
        end
        hold off;
    
        % plot the matches on the second image
        figure(2);
        clf;
        colormap('gray');
        imshow(im2);
        hold on;
        for ind = 1: size(match,1)
            plot(match(ind,3),match(ind,4), 'o');
        end
        hold off;
 
        % plot the matches of the the two images
        figure(3);
        clf;
        colormap('gray');
        im3 = appendimages(im1,im2);
        imagesc(im3);
        hold on;
        cols1 = size(im1,2);
        for ind = 1: size(match,1)
            line([match(ind,1) match(ind,3)+cols1], [match(ind,2) match(ind,4)], 'Color', 'c');
        end
        hold off;
