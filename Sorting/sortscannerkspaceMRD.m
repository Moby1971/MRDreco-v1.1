function [kspace,trajectory] = sortscannerkspaceMRD(app,kspace_in,parameters,ktable)


app.TextMessage('Sorting k-space with scanner table ...');


% dimensions
[dimx,dimy,dimz,nrrep,nrfa,nrte] = size(kspace_in);
kspace = zeros(size(kspace_in));
trajectory = ones(dimx*dimy*dimz*nrrep*nrfa*nrte,6);


% navigator yes or no, for RARE echo train correction
if parameters.nav_on == 1
    firsty = parameters.VIEWS_PER_SEGMENT;
    app.TextMessage('Navigator detected ...');
else
    firsty = 0;
end


% counter
tcnt = 1;


% some parameters
ktable = ktable + 1;


% loop over all dimensions
for te_cnt=1:nrte
    
    for fa_cnt=1:nrfa
        
        for nr_cnt=1:nrrep
            
            for k=1:dimz
                
                % determine shift of echoes based on navigator echoes
                if firsty>0
                    
                    % calculate phase difference between even and odd echoes
                    for nav=1:firsty
                        navecho1 = squeeze(kspace_in(round(dimx/2)+1,1,k,nr_cnt,fa_cnt,te_cnt));
                        navecho2 = squeeze(kspace_in(round(dimx/2)+1,nav,k,nr_cnt,fa_cnt,te_cnt));
                        PHshift(nav) = phase(navecho2) - phase(navecho1);
                    end
                    
                    % sorting including phase correction based on navigator
                    for j = firsty+1:dimy
                        idx = mod(j-firsty+1,firsty)+1;
                        y = ktable(j)+round(firsty/2);
                        kspace(:,y,k,nr_cnt,fa_cnt,te_cnt) = kspace_in(:,j,k,nr_cnt,fa_cnt,te_cnt).*exp(-1i*PHshift(idx));
                    
                        for w = 1:dimx
                            
                            % fill the k-space trajectory array
                            trajectory(tcnt,1) = w;
                            trajectory(tcnt,2) = y;
                            trajectory(tcnt,3) = k;
                            trajectory(tcnt,4) = nr_cnt;
                            trajectory(tcnt,5) = fa_cnt;
                            trajectory(tcnt,6) = te_cnt;
                            tcnt = tcnt + 1;
                            
                        end
                    
                    end
                    
                else
                    
                    % sorting without phase correction
                    for j = firsty+1:dimy
                        y = ktable(j)+round(firsty/2);
                        kspace(:,y,k,nr_cnt,fa_cnt,te_cnt) = kspace_in(:,j,k,nr_cnt,fa_cnt,te_cnt);
                        
                        for w = 1:dimx
                            
                            % fill the k-space trajectory array
                            trajectory(tcnt,1) = w;
                            trajectory(tcnt,2) = y;
                            trajectory(tcnt,3) = k;
                            trajectory(tcnt,4) = nr_cnt;
                            trajectory(tcnt,5) = fa_cnt;
                            trajectory(tcnt,6) = te_cnt;
                            tcnt = tcnt + 1;
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end


end