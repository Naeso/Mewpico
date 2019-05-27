pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- main

--mewpico
--by naeso

--star background snippet at https://www.lexaloffle.com/bbs/?tid=29920
--by dr4ig

--[[
if you want to read the code
please use visual studio or
another kind of editor
(it would be easier)
]]

function _init()
    --generated constants
    left,right,up,down,fire1,fire2=0,1,2,3,4,5
    black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

    --does the player passes the title screen ?
    titlescreen=true

    --bool for the animation on the title screen
    titlescreenanimtaion=false

    --coundown for the animation title screen ship
    mewanimationshipcdnt=80

    --collection for the clouds on the title screen
    sky={}

    createcloud()

    --ship's initial position and horizontal/vertical speed
    mew = {x=110, y=140}
    --y position of where the hearts will be displayed on the bottom board
    heartdisplay={y=128}
    
    --collection containg all parts of the ship
    ship={}
    --x and y positions used for placing each part of the ship
    xpart,ypart=0,0

    --if any damage is taken, and if the ship flashes after a hit.
    dmgtaken=false
    clink=false
    --duration of the said "flash" animation in milliseconds
    countdmgtaken=60

    --collection containing all bullets shot
    shoots={}
    --iniital speed of the bullet
    speedbullet=3

    --collection containing all stars
    stars={}

    --collection for particles of the thurster and the ennemies.
    smoke={}
    debris={}
    --collection for hearts
    objects={}
    
    --"yeah" cat face animation boolean and duration in milliseconds
    yeah=false
    yeahcdn=60

    --if the particules sent by the thruster should be viewable.
    displayparticules=true
    
    --if the game is over, and the random message that will pop.
    gameover=false
    msgdeath=rnd(15)

    --total life, score, and score multiplier (score*scoremultip)
    life=4
    score=0
    scoremultip=1

    --collection of all the ennemies
    ennemy={}
    --used in the function for spawning ennemies. is used as a x or y coord.
    ennemyspawn=0
    --indicates if a group of ennemies is currently displayed on screen.
    ennemyalreadydisplayed=false
    --speed of the ennemies
    speedbadguy=2

    --used to make a little animation of "dance" for the ennemies.
    rotation=0
    flipy=false
    flipx=true

    --scoreboard display position (y: 118)
    maxdisplayy=118

    createstars()
    createcloud()
    buildship()

end

--all functions are explained in their relative tabs

function _update()

    if (titlescreen) then
        movecloud()
        shiptitlescreen()
        thruster()
        gamestart()
    else
        replay()
        getshipstatus()
        movemew()
        shoot()
        thruster()
        shoottouches()
        bullets()
    
        --if a group of enemies should spawn or not
        if (rnd(60)<30) then
            ennemygroup()
        end
    
        ennemyia()
        ennemyhitship()
    
        gamespeed()
        yeahface()
        hearts()
        getlife()
        cleardebris()
        rotateennemy()
        movestars()
    end
end

function _draw()
    if (titlescreen) then
        drawtitlescreen()
        drawship()
    else
        cls()

        drawstars()

        drawobjets()
    
        drawennemy()
    
        drawship()
    
        drawstatusscreen()
    
        deathscreen()
    end
end

-->8
--ship functions

--initial logicial building of the ship. (all 4 parts)
function buildship()
    local xpart = mew.x
    local ypart = mew.y
    part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
    add(ship, part)
    ypart-=8
    part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
    add(ship, part)
    ypart+=8
    xpart-=8
    part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
    add(ship, part)
    xpart+=16
    part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
    add(ship, part)
end

--get the current status of the ship depending of the current life
function getshipstatus()
    --deleting all parts of the collection in order to update correctly
    for part in all(ship) do
        del(ship,part)
    end
    --if the ship didn't lost any live, that's good, so just call the initial function that build the ship !
    if (life>=4) then
        buildship()
    end
    --the rest isn't so hard : each time the life decrease, we just get rid of the lines that adds the latest part of the ship.
    if (life==3) then
        local xpart = mew.x
        local ypart = mew.y
        part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
        add(ship, part)
        ypart-=8
        part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
        add(ship, part)
        ypart+=8
        xpart-=8
        part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
        add(ship, part)
    end
    if (life==2) then
        local xpart = mew.x
        local ypart = mew.y
        part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
        add(ship, part)
        ypart-=8
        part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
        add(ship, part)
    end
    if (life==1) then
        local xpart = mew.x
        local ypart = mew.y
        part={x=xpart,y=ypart,x1=xpart+7,y1=ypart+7,w=(xpart+7)-xpart,h=(ypart+7)-ypart,}
        add(ship, part)
    end
end

--move the ship
function movemew()
    --thruster particules is showed when you push any button (or not) but down.
    --of course, to avoid our ship going outside of the screen, there is a limit (second condition)
    if (not gameover) then
        
        displayparticules=true

        if (btn(right) and (mew.x+16)<129) then 
            mew.x+=mew.sy
        end
    
        if (btn(left) and (mew.x-8)>0) then 
            mew.x-=mew.sy
        end
    
        if (btn(up) and (mew.y-10)>0) then 
            mew.y-=mew.sx
        end
    
        if (btn(down) and (mew.y+8)<maxdisplayy) then 
            mew.y+=mew.sx
            displayparticules=false
        end
    end
end

--shoot function
function shoot()
    if (not gameover) then
        if (btnp(4)) then
            bullet ={x=mew.x, y=mew.y-7, x1=mew.x+2, y1=mew.y+7, w=mew.x+2-mew.x, h=mew.y+8-mew.y-8}
            add(shoots, bullet)
            sfx(0,3)
            --a little drawback each time you shoot to add a little reaslism
            if ((mew.y+8)<maxdisplayy and btn(up)==false) then 
                mew.y+=1
            end
        end
    end
end

--when a bullet touches an ennemy and heart generation
function shoottouches()
    for badguy in all(ennemy) do
        for bullet in all(shoots) do
            if (bullet.x < badguy.x + badguy.w and
                bullet.x + bullet.w > badguy.x and
                bullet.y < badguy.y + badguy.h and
                bullet.y + bullet.h > badguy.y) then
                del(shoots, bullet)
                local xheart = badguy.x
                local yheart = badguy.y
                --generation of a heart
                if (rnd(300)<=10) then
                    heart={x=xheart, y=yheart, x1=xheart+7, y1=yheart+7, w=(xheart+7)-xheart, h=(yheart+7)-yheart}
                    add(objects, heart)
                end
                --generation of particles for the ennemy's death
                for i=0,rnd(7) do
                    particle={x=xheart+rnd(7),y=yheart+rnd(7),originx=xheart+5,originy=yheart+5}
                    add(debris, particle)
                end
                del(ennemy, badguy)
                sfx(3,3)
                score+=(badguy.pts*scoremultip)
            end
        end
    end
end

--thruster particles system
function thruster()
    --based on the part of the ships that are still there, the particles positions are different.
    local xpart = mew.x
    local ypart = mew.y
    if (displayparticules) then
        if (life>=4) then
            particle={x=(xpart-6)+rnd(4),y=ypart+3}
            add(smoke, particle)
            particle={x=(xpart+10)+rnd(4),y=ypart+3}
            add(smoke, particle)
        end
        if (life==3) then
            particle={x=(xpart-6)+rnd(4),y=ypart+3}
            add(smoke, particle)
        end
        if (life==2) then
            particle={x=(xpart+2)+rnd(5),y=ypart+3}
            add(smoke, particle)
        end
        if (life==1) then
            particle={x=(xpart+2)+rnd(4),y=ypart+7}
            add(smoke, particle)
        end
    end

    --deleting particules
    for part in all(smoke) do
        part.y+=2
        if (part.y>=mew.y+20) del(smoke,part)
        if (part.x<=mew.x-7 or part.x>=mew.x+14) del(smoke,part)
    end

    --if down is pressed, we desactivate the particles
    if (not displayparticules) then
        for part in all(smoke) do
            del(smoke, part)
        end
    end
end

--bullet function
function bullets()
    for bullet in all(shoots) do
        bullet.y-=speedbullet
    end

    --if the bullet exits the screen, we delete it.
    for bullet in all(shoots) do
        if (bullet.y<=-10) then
            del(shoots, bullet)
        end
    end
end

--drawing the ship and thruster particles
function drawship()
    --if clink is true, we don't drawn the ship
    --this is what make our "flash" animation to work when taking a hit.
    --the ship is drawn depending of life's current value
    if (not clink) then
        if (life>=4) then
            spr(2,mew.x,mew.y)
            spr(1,mew.x,mew.y-8)
            spr(3,mew.x-8,mew.y)
            spr(3,mew.x+8,mew.y,1,1,true,false)
        end
        if (life==3) then
            spr(2,mew.x,mew.y)
            spr(1,mew.x,mew.y-8)
            spr(3,mew.x-8,mew.y)
        end
        if (life==2) then
            spr(2,mew.x,mew.y)
            spr(1,mew.x,mew.y-8)
        end
        if (life==1) spr(1,mew.x,mew.y)
    end

    --thruster particles.
    if (displayparticules) then
        for part in all(smoke) do
            if (rnd(10)<=5) then
                pset(part.x,part.y,red)
            else
                pset(part.x,part.y,orange)
            end
        end
    end
end

-->8
-- ennemy functions

--all the possible ennemies that could spawn into the game
function ennemygroup()
    --this value determines if the ennemy will spawn or not.
    local monster=0

    if (not gameover) then
        if (not ennemyalreadydisplayed) then
            monster=rnd(30)
            if (monster<5) then
                if (rnd(80)>=20) then
                    ennemyalreadydisplayed=true
                    ennemyspawn=rnd(100)
                    --rnd() function have a littel problem : you can't choose the minimum value.
                    --so we use this if in order to define an minimum value.
                    if (ennemyspawn<=20) then
                        ennemyspawn=mew.y+10
                    end
                    ennemy={}
                    local ennemyx=-10
                    for i=0,5,1 do
                        rekal={type="rekal", x=ennemyx, y=ennemyspawn, x1=ennemyx+7, y1=ennemyspawn+7, w=(ennemyx+7)-ennemyx, h=(ennemyspawn+7)-ennemyspawn, pts=5}
                        add(ennemy, rekal)
                        --each time we're putting the next ennemy a little further than the last one
                        ennemyx-=15
                    end
                end
            end
            if (monster>10 and monster<15) then
                if (rnd(80)>=20) then
                    ennemyalreadydisplayed=true
                    ennemyspawn=rnd(115)
                    --rnd() function have a littel problem : you can't choose the minimum value.
                    --so we use this if in order to define an minimum value.
                    if (ennemyspawn<=40) then
                        ennemyspawn=40
                    end
                    ennemy={}
                    local ennemyy=-10
                    local turn=rnd(100)
                    --determines when the ennemy will turn (what y corrd the ennemy will turn)
                    if (turn<=50) then
                        turn=50
                    end
                    local here=false
                    if (rnd(9)>=4) then
                        here=true
                    end
                    for i=0,3,1 do
                        bughe={type="bughe", x=ennemyspawn, y=ennemyy, x1=ennemyspawn+7, y1=ennemyy+7, w=(ennemyspawn+7)-ennemyspawn, h=(ennemyy+7)-ennemyy, pts=10, turns=turn, where=here}
                        add(ennemy, bughe)
                        --each time we're putting the next ennemy a little further than the last one
                        ennemyy-=15
                    end
                end
            end
            if (monster>20 and monster<23) then
                if (rnd(80)>=20) then
                    ennemyalreadydisplayed=true
                    ennemyspawn=rnd(80)
                    --rnd() function have a littel problem : you can't choose the minimum value.
                    --so we use this if in order to define an minimum value.
                    if (ennemyspawn<=20) then
                        ennemyspawn=20
                    end
                    ennemy={}
                    local ennemyy=-10
                    for i=0,1,1 do
                        kaalh={type="kaalh", x=ennemyspawn, y=ennemyy, x1=ennemyspawn+7, y1=ennemyy+7, w=(ennemyspawn+7)-ennemyspawn, h=(ennemyy+7)-ennemyy, pts=15, wait=60, where=false}
                        add(ennemy, kaalh)
                        --each time we're putting the next ennemy a little further than the last one
                        ennemyspawn+=40
                    end
                end
            end
        end
    end
end

--when an ennemy hit the ship
function ennemyhitship()
    --if an ennemy already hit the ship, nothing will happen
    if (dmgtaken) then
        countdmgtaken-=1
        --"flash" animation for the ship
        if (not clink) then
            clink=true
        else
            clink=false
        end
        if (countdmgtaken==0) then
            countdmgtaken=60
            dmgtaken=false
            clink=false
        end
    else
        for badguy in all(ennemy) do
            for part in all(ship) do
                if (part.x < badguy.x + badguy.w and
                    part.x + part.w > badguy.x and
                    part.y < badguy.y + badguy.h and
                    part.y + part.h > badguy.y) then
                    del(ship, part)
                    del(ennemy,badguy)
                    life-=1
                    sfx(1,2)
                    dmgtaken=true
                end
            end
        end
    end
end

--all the ia (where the enemies are going)
function ennemyia()
    for badguy in all(ennemy) do
        if (badguy.type=="bughe") then
            if (badguy.y>badguy.turns) then
                if (badguy.where) then
                    badguy.x-=speedbadguy+2
                else
                    badguy.x+=speedbadguy+2
                end                
            else
                badguy.y+=speedbadguy
            end
        end

        if (badguy.type=="rekal") then
            badguy.x+=speedbadguy
        end

        if (badguy.type=="kaalh") then
            if (badguy.wait<=badguy.wait and badguy.wait>40) then
                badguy.y+=0.5
            end

            if (badguy.wait==0) then
                badguy.where=true
                badguy.y+=7+speedbadguy
            end
            if (not badguy.where) badguy.wait-=1
        end
    end

    --if the last ennemy left the screen, we delete it from the collection
    if (ennemyalreadydisplayed) then
        if (ennemy[#ennemy]!=nil) then
            if (ennemy[#ennemy].x>130 or ennemy[#ennemy].y>130 or (ennemy[#ennemy].x<-20 and ennemy[#ennemy].type=="bughe")) then
                ennemyalreadydisplayed=false
                ennemy={}
            end
        else
            ennemyalreadydisplayed=false
        end
    end
end

--draws the ennemies
function drawennemy()
    for badguy in all(ennemy) do
        if (badguy.type=="bughe") then
            spr(48,badguy.x,badguy.y)
        end
        if (badguy.type=="rekal") then
            spr(50,badguy.x,badguy.y,1,1,false,flipy)
        end
        if (badguy.type=="kaalh") then
            spr(49,badguy.x,badguy.y)
        end
    end
end

-->8
--engine and core functions

--hearts function, how they move and get deleted
function hearts()
    for heart in all(objects) do
        heart.y+=0.5
        heart.y1+=0.5
    end

    for heart in all(objects) do
        if (heart.y>130) del(objects, heart) 
    end
end

--when touching a heart
function getlife()
    for heart in all(objects) do
        for part in all(ship) do
            if (part.x < heart.x + heart.w and
                part.x + part.w > heart.x and
                part.y < heart.y + heart.h and
                part.y + part.h > heart.y) then
                del(objects,heart)
                if (life<4) then
                    life+=1
                end
                sfx(2,3)
                yeah=true
            end
        end
    end 
end

--draw the bullet, the hearts, and the particles when an ennemy dies
function drawobjets()
    for bullet in all(shoots) do
        spr(34,bullet.x,bullet.y)
    end

    for heart in all(objects) do
        spr(32,heart.x,heart.y)        
    end

    for part in all(debris) do
        if (rnd(10)<=5) then
            pset(part.x,part.y,pink)
        else
            pset(part.x,part.y,peach)
        end
    end
end

--drawn the bottom status screen
function drawstatusscreen()
    -- board for score, hearts and cat face
    rectfill(0,119,128,128,dark_blue)
    rectfill(0,maxdisplayy,128,maxdisplayy,white)
    
    print("score:"..score,1,121,white)

    --cat face
    if (dmgtaken==true and life>0) spr(17,60,119)
    if (dmgtaken==false and life>=0) spr(16,60,119)
    if (yeah) spr(18,60,119)
    if (life==0) spr(19,60,119)

    --depending of the current life's value, display an accurate number of hearts
    for i=1,life,1 do
        spr(32,heartdisplay.y-(9*i),119)
    end
end

--get track of the score and increase difficulty
function gamespeed()
    if (score>=150 and score<=300) then
        mew.sx=2.5
        mew.sy=1.5
        speedbadguy=3
    end
    if (score>=300 and score<=450) then
        mew.sx=3
        mew.sy=2
        speedbadguy=3.5
    end    
    if (score>=450 and score<=600) then
        mew.sx=3.5
        mew.sy=2.5
        speedbadguy=4
        scoremultip=2
    end
    if (score>=600 and score<=1000) then
        mew.sx=4
        mew.sy=3
        speedbadguy=5
    end
    if (score>=1500 and score<=2000) then
        mew.sx=4.5
        mew.sy=3.5
        speedbadguy=6
        scoremultip=3
    end
    if (score>=3000 and score<=5000) then
        mew.sx=5
        mew.sy=4
        speedbadguy=7
    end
    if (score>=7000 and score<=9999) then
        mew.sx=5.5
        mew.sy=4.5
        speedbadguy=8
        scoremultip=4
    end
end

--create the clouds on the title screen
function createcloud()
    local totcloud=5
    for i=0,totcloud do
        cloud={x=rnd(200),y=rnd(80)}
        
        add(sky,cloud)
    end
end

--move the clouds on the title screen
function movecloud()
    for cloud in all(sky) do
        if (cloud.x>(-15)) then
            cloud.x-=0.1
        else
            cloud.x=130
        end
    end
end

--draw the clouds
function drawcloud()
    for cloud in all(sky) do
        spr(70,cloud.x,cloud.y,2,1)
    end
end

--initial function to create the background stars
function createstars()
    local totstars=125
    for i=1,totstars do
        local tc=flr(rnd(3)+1)
            
        if (tc==1) then sc=13 end
        if (tc==2) then sc=6 end
        if (tc==3) then sc=7 end
            
        add(stars,{
            x=rnd(128),-- random "x" pos.
            y=rnd(128),-- random "y" pos.
            sp=tc*scoremultip,     -- speed from 1-3.
            sc=sc      -- star color.
        })
    end
end

--moving the background
function movestars()
    for st in all(stars) do
        st.y+=st.sp
        
        if (st.y>=128) then
         st.y=0
         st.sp=rnd(3)+1
        end
    end
end

--draw the stars
function drawstars()
    for st in all(stars) do
        pset(st.x, st.y, st.sc)
    end
end

--clean the particles an ennemy emits when he dies
function cleardebris()
    for part in all(debris) do
        part.y+=0.5
        if (part.y>part.originy+15) del(debris,part)
    end
end

--dead, not a big sooprise
function deathscreen()
    --game over yeaaaaaah
    if (life==0) then
        music(-1, 500)

        gameover=true
        print("game over",45,60,white)
        print("your score : ",25,67,white)
        print(score,80,67,yellow)

        --[[
            depending of the value, we choose one of the messages listed here
            this isn't very clean, initally i was going to use a function but
            i wasn't able to make it work. so instead i come up with this solution
            which is mostly the same anyways
        ]]

        local message=""

        if(msgdeath>=0 and msgdeath<=1) message="it's kinda cold here..."
        if(msgdeath>=1 and msgdeath<=2) message="cat paradise is far enough"
        if(msgdeath>=2 and msgdeath<=3) message="the cat is dead !"
        if(msgdeath>=3 and msgdeath<=4) message="cat as been deleted"
        if(msgdeath>=4 and msgdeath<=5) message="'sudo rm -r cat'"
        if(msgdeath>=5 and msgdeath<=6) message="mewwowh-*boom*-ded"
        if(msgdeath>=6 and msgdeath<=7) message="welp, you're dead."
        if(msgdeath>=7 and msgdeath<=8) message="it sucks to be dead"
        if(msgdeath>=8 and msgdeath<=9) message="cat is now a bag of meat"
        if(msgdeath>=9 and msgdeath<=10) message="poor cat..."
        if(msgdeath>=10 and msgdeath<=11) message="kitty forever in space"
        if(msgdeath>=11 and msgdeath<=12) message="cat joined the stars"
        if(msgdeath>=12 and msgdeath<=13) message="you're now a satelite"
        if(msgdeath>=13 and msgdeath<=14) message="report : cat taken down"
        if(msgdeath>=14 and msgdeath<=15) message="this cat is on fire"

        print(message,15,50,red)

        print("press z or ❎ to retry",30,90,red)
    end
end

function replay()
    if (gameover and btn(fire1)) then
        dmgtaken=true
        mew = {x=60, y=60, sx=2, sy=1}
        music(0)
        life=4
        gameover=false
        score=0
        scoremultip=1
        speedbadguy=2
    end
end

function drawtitlescreen()
    rectfill(0,0,128,128,dark_blue)

    circfill(120,0,15,white)
    circ(120,0,15,dark_gray)
    
    drawcloud()
    
    spr(64,40,30,6,48)
    print("2019 - naeso",1,110,light_gray)
    print("star background by dr4ig",1,119,light_gray)
    
    print("press z or ❎",48,80,dark_gray)
end

function gamestart()
    if (titlescreenanimtaion and mewanimationshipcdnt==0) then
        mew = {x=60, y=60, sx=2, sy=1}
        titlescreen=false
        music(0)
    end
end

-->8
--animations functions

--title screen cat ship moving
function shiptitlescreen()
    if (titlescreenanimtaion) then
        if (mewanimationshipcdnt>80) mew.y-=1
        if (mewanimationshipcdnt==70) sfx(4,3)
        if (mewanimationshipcdnt>80) mew.y-=1
        if (mewanimationshipcdnt<60 and mewanimationshipcdnt>30) mew.y-=4
        if (mewanimationshipcdnt<30) mew.y-=6
        mewanimationshipcdnt-=1
    else
        if (btn(fire1)) then
            titlescreenanimtaion=true
            buildship()
            sfx(3,3)
        end
    end
end

--"yeah" cat face when you collect an heart
function yeahface()
    if (yeah) then
        yeahcdn-=1
        if (yeahcdn==0) then
            yeah=false
            yeahcdn=60      
        end
    end

end

--"rotation" annimation for the ennemy.
--not a real, true rotation, but gives the ennemy more alive.
function rotateennemy()
    rotation+=1
    if(rotation==3) then
        if (not flipy) then
            flipy=true
        else
            flipy=false
        end
        rotation=0
    end
end

__gfx__
0000000000088000dddddddd00000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000555500d6d6d66d00005ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700055dd550ddd6d6dd0005dddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700005499450dddddddd005ddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700059b99b955dddddd505dddd55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700599ee99505d00d5005d00d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000542dd2450000000005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000554994550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09000090090000900900009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e9009e00e9009e00e9009e099900999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e9999e00e4994e00e9999e00e9999e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09499490049999400449999009499490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04b99b4009b99b9009b9944004b99b40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
499ee994499ee9944d9ee99449ceec94000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
042dd240042dd24004ddd24004c99c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40499404404dd4044049940440cddc04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08800888000550000000000000333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8ee88ee8005dd5000000000003bbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8eeee7e8005dd5000000000003bb7b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8eeee7e805dddd50000aa00003bb7b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8eeeeee805d66d50000aa00003bbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08eeee8005d6dd5000000000033bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008ee80005dddd5000000000003bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000005005000000000000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f000000f00c66c000440004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f006600f06666660004c044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f6866f00566665000088c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f066860f050cc05000c8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f006600f050ee0500440c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f000000f0d0000d00400044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900000000000000000000000000000000000000000000000000777777000000000000000000000000000000000000000000000000000000000000000000000
00999000000099000000000000000000000000000000000000007777777770000000000000000000000000000000000000000000000000000000000000000000
00999000000999000000999999999000000000000000000000777777777777700000000000000000000000000000000000000000000000000000000000000000
00999900000999009999999999999099000000000990000007777777777777760000000000000000000000000000000000000000000000000000000000000000
00999990099999009999999999999099000000000990000007777777777777760000000000000000000000000000000000000000000000000000000000000000
00999999099999009999999999999099000000000990000006777777777777600000000000000000000000000000000000000000000000000000000000000000
009999999999990999999900000000ee990000099ee0000000666677777766000000000000000000000000000000000000000000000000000000000000000000
009999999999990999900000000000ee990000099ee0000000000066666600000000000000000000000000000000000000000000000000000000000000000000
009999999999990999900000000000ee999000999ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009999999999990999900000000000ee999999999ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999099009999099999999999000099449999944990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000009990999999999999000099449999944990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000009990999999999990000099449999944990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000009990999990000000000044bb99999bb440000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000099990999999000000000044bb99999bb440000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0999000009990099999999000000449999eeeee99994400000000000000000000000000000000000000000000000000000000000000000000000000000000000
0999000009990099999999999990449999eeeee99994400000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000009999999990004422ddddd22440000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000999999990004422ddddd22440000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000009999000004422ddddd22440000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000004400449999944004400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008000000004400449999944004400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000097f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000a777e0077770777700777007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000b7d00770770077007700077077000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000c000777770077007700077077000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000770000077007700077077000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000770000777707777077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000222501a25015250112500f2500c2500a25008250082500825008250092500a2500d250182501d25022250292502c25006050060500605001000010000100001000010000100001000010000100001000
010600003f670336702c670206701b660186601566013650106500d6500b640086400664004630036300263002610016100161002600026000260002600026000260002600016000160001600016000160001600
0002000027050247501d7501a75016750147501455014550145501554016540185401b540205302b5302f5002e70030700307002f7002f7002ae002ae002ae002ae002ae002ae002ae002ae00000000000000000
0002000017430154301243013430154301a4300105001050010002410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000003670036700366003660046500565006650086500b6500f65013650186301c63021630276302d63033630366203862001000010003f6003f6003f6003f60000000000000000000000000000000000000
000700002b5002d500315003850034500345001e5401e5401e5401e5401d5001d500235402354023540235401a5002d5002854028540285402854000500005002154021540215402154026540265402654026540
000700001e730067001e73006700217300670023730067001c730067001c73006700217300670023730067001e730067001e73006700217300670023730067001c730067001c7300670021730067002373006700
010700000b0400b0300b0200b0100000010600000000000010650106401063010620106100000000000000000b0400b0300b0200b0100b0000000000000106001065010640106301062010610000000000000000
000700002554025540255402554000500005000050024500255302553025530255302450024500245002450025520255202552025520245002450024500005000050000500005000050000500005000050000500
000705001e730187001e73018700217301870023730187001c730187001c730187002173018700237301870020730187002073018700217302470028730187002073018700207301870021730247002a73000700
0007000025540255402554025540255402554025540255402a5402a5402a5402a5402a5402a5402a5402a54023540235402354023540235402354023540235402854028540285402854028540285402854028540
0007000025540255402554025540255402554025540255402a5402a5402a5402a54025540255402554025540315403154031540315402a5402a5402a5402a5403654036540365403654031540315403154031540
000700002f5402f5402f5402f5402f5402f5402f5402f5402f5402f54000500005002d5402d5402f5402f5403154031540315403154000500005002a5402a5402a5402a540005000050031540315403154031540
000700002173021730217302173028730247002a730187002173021730217302173028730247002a730187002073020730207302073028730247002a730187002073020730207302073028730247002a73000700
000700002f5402f5402f5402f5402d5402d5402c5402c5402c5402c540005000050023540235402f5402f5402d5402d5402d5402d5402c5402c5402a5402a5402a5402a540245002450028540285402854028540
000700002073020730207302073028730187002a730007002073020730207302073028730247002a730187002173021730217302173028730247002a730187002173021730217302173028730247002a73000700
000700002154021540215402154021540215402154021540235402354023540235402354023540235402354025540255402554025540255402554025540255402754027540275402754027540275402754027540
000700002173021730217302173028730247002a73024700207302073020730207302a7302a7302c7302c730217302173021730217302d7302d7302f7302f7302373023730237302373031730317300050000500
000700002854028540285402854028540285402854028540285402854000500005002c5402c5402c5402c5402a5402a5402a5402a540245002450025540255402554025540255402a5402a5402a5402a5402a540
00070000007000070031730317302c7302c7302873028730257302573020730207301c7301c7301973019730007000070031730317302e7302e7302a7302a730257302573022730227301e7301e7301973019730
000700002854028540285402854028540285402854028540285402854024500245002c5402c5402c5402c5402a5402a5402a5402a5402a5402a5402c5402c5402c5402c5402c5402c5402e5402e5400050000500
000700002f5402f5402f5402f5402f5402f5402f5402f5402f5402f54024500245003254032540325403254031540315403154031540005000050034540345403454034540005000050039540395400050000500
00070000007000050032730327302f7302f7302b7302b730267302673023730237301f7301f7301a7301a7300070000700007000070031730317302d7302d7302873028730257302573021730217301c7301c730
0005000038540395303a5303b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b5203b520305003050039540395403b5403b540
000700001b7301b7301e7301e7301d7301d73020730207301e7301e73023730237302773027730297302973019730197301b7301b7301e7301e7302373023730257302573027730277302a7302a7302f7302f730
000700003d5403d54036540365403454034540365403654031540315403d5403d54036540365403b5403b5402f5402f5403954039540385403854036540365403854038540365403654038540385403654036540
000700002d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c730
00070000395403954031540315402f5402f54031540315402f5402f540345403454000500005003b5403b5403b5403b5403954038540345403454034540345402f5402f5402f5402f5402f5402f5402f5402f540
000700002d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302d7302d7302c7302c7302a7302a730287302873025730257302373023730
0007000031540315402a5402a54028540285402a5402a540285402854031540315402a5402a540345403454031540315402d5402d5402a5402a540345403454031540315402c5402c5402a5402a5403154031540
000700002573025730237302373025730257302373023730257302573023730237302573025730237302373025730257302373023730257302573023730237302573025730237302373025730257302373023730
000700003154031540335403354000500005002a5402a5402a5402a5402a5402a540245002450031540315403154031540335403354030500245002a5402a5402a5402a5402a5402a55000500005000050000500
00070000257302573023730237302573025730237302373025730257302373023730257302573023730237302573025730237302373025730257302373023730217302173020730207301e7301e7301c7301c730
0007000031540315402a5402a54028540285402a5402a540255402554031540315402a5402a5402f5402f54023540235402d5402d5402c5402c5402a5402a5402c5402c5402a5402a5402c5402c5402a5402a540
000700001e7301e730217302173028730287301e7301e730217302173028730287301e7301e730217302173028730287302073020730217302173028730287302073020730217302173028730287302073020730
000700002d5402d5402554025540235402354025540255402354023540285402854024500245002f5402f5402f5402f5402d5402c540285402854028540285402354023540235402354025540255402554025540
000700001e7301e730217302173028730287301e7301e730217302173028730287301e7301e730217302173028730287302073020730217302173028730287302073020730217302173028730287302a7302a730
000700002854028540255402554028540285402a5402a54028540285402a5402a5402c5402c5402d5402d5402c5402c5402d5402d5402f5402f54031540315403454034540345403154031540315403454035540
000700003654036540365403654036540365403050030500365303653036530365303653036530305003050036520365203652036520365203652030500305003651030500385403050039540305003b54030500
000700003d5403d54036540365403454034540365403654031540315403d5403d5403654036540345403454034540345403954039540385403854039540395403854038540395403954038540385403954039540
00070000395403954038540385403654036540315403154024500245002f5402f54024500305003b5403b5403b5403b5403954039540305003050038540385403050030500345403454034540345403454034540
0007000031540315402a5402a54028540285403454034540365403654031540315402a5402a54039540395403654036540345403454031540315403b5403b5403154031540395403954038540385403654038540
000700003854038540395403954030500305003654036540365403654036540365403050030500385403854038540385403954039540395003650036540365403654036540365403654036540365403050030500
000700003d5403d54036540365403454034540365403654031540315403d5403d54036540365403b5403b5402f5402f5403954039540385403854039540395403854038540395403954038540385403954039540
00070000395403954031540315402f5402f54031540315402f5402f540345403454030500305003b5403b5403b5403b5403d5403d54000500005003b5403b5400050000500365403654036540365403654036540
0007000000500005000050000000315403154036540365403154031540385403854039540395403954039540395403954038540385403050030500395403954038540385403b5403b5403b5403b5403454034540
0007000023730237302a7302a730007000070023730237302a7302a730007000070023730237302a7302a730007000070023730237302a7302a730007000070023730237302a7302a73000700007000070000700
0007000000000000003d5503d55000000000003d5403d5403d5403d5403d5303d5303d5303d5203d5203d5203d5103d5103d51000000000000000000000000000000000000000000000000000000000000000000
010700000b0000b0000b0000b000000001060010600106001060010600106000b000000001060010600106000b0000b0000b0000b000000001060010600106001060010600106000b00000000106001060010600
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 05060744
00 08090744
00 05060744
00 0a090744
00 05060744
00 08090744
00 05060744
00 0b090744
00 0c0d0744
00 0c0d0744
00 0e0f0744
00 10110744
00 12130744
00 14130744
00 15160744
00 17184744
00 191a0744
00 1b1c0744
00 1d1e0744
00 1f200744
00 21220744
00 23240744
00 251e0744
00 26200744
00 271a0744
00 281c0744
00 291e0744
00 2a200744
00 2b220744
00 2c240744
00 2d2e0744
02 2f5f0744

