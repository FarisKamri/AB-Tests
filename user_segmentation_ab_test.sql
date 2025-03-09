-- Randomised AB test allocation

drop table if exists abtest_pos;
drop table if exists abtest_neg;

CREATE TABLE IF NOT EXISTS abtest_pos (
      user_id       bigint 
    , user_group    varchar 
    , treatment     varchar 
);

CREATE TABLE IF NOT EXISTS abtest_neg (
      user_id       bigint 
    , user_group    varchar 
    , treatment     varchar 
);

DELETE FROM abtest_pos;
DELETE FROM abtest_neg;

insert into abtest_pos (
select * from (
    with 
    user_base as (
        select 
              a.user_id
            , b.user_group
        from user_segmentation a 
        left join user_grouping b on a.user_id = b.user_id 
        where region = 'TargetRegion' -- Replace with your filter condition
        and   segment_type = 'positive'
    )

, raw_group_1 as (
    select distinct
        user_group
        , user_id
        , random() as random_no
    from user_base
    where user_group = 'G1'
)

, raw_group_2 as (
    select distinct
        user_group
        , user_id
        , random() as random_no
    from user_base
    where user_group = 'G2'
)

, raw_group_3 as (
    select distinct
        user_group
        , user_id
        , random() as random_no
    from user_base
    where user_group = 'G3'
)

  
-- Control group = 95%
select user_id, user_group,
case when random_no <= 0.05 then 'CG'
     else 'TG'
     end as treatment
from raw_group_1

union all

select user_id, new_seg,
case when random_no <= 0.05 then 'CG'
     else 'TG'
     end as treatment
from raw_group_2

union all

select user_id, new_seg,
case when random_no <= 0.05 then 'CG'
     else 'TG'
     end as treatment
from raw_group_3

) as ab_pos;


insert into abtest_neg (
select * from (
    with 
    user_base as (
        select 
              a.user_id
            , b.user_group
        from user_segmentation a 
        left join user_grouping b on a.user_id = b.user_id 
        where region = 'TargetRegion' -- Replace with your filter condition
        and   segment_type = 'negative'
    )

, raw_group_1 as (
    select distinct
        user_group
        , user_id
        , random() as random_no
    from user_base
    where user_group = 'G1'
)

, raw_group_2 as (
    select distinct
        user_group
        , user_id
        , random() as random_no
    from user_base
    where user_group = 'G2'
)

, raw_group_3 as (
    select distinct
        user_group
        , user_id
        , random() as random_no
    from user_base
    where user_group = 'G3'
)
-- Control group = 95%
select user_id, user_group,
case when random_no <= 0.05 then 'CG'
     else 'TG'
     end as treatment
from raw_group_1

union all

select user_id, new_seg,
case when random_no <= 0.05 then 'CG'
     else 'TG'
     end as treatment
from raw_group_2

union all

select user_id, new_seg,
case when random_no <= 0.05 then 'CG'
     else 'TG'
     end as treatment
from raw_group_3


) as ab_neg;


-- Summary statistics for A/B test group distribution
select treatment, count(distinct user_id) as pos_user_count
from ab_test_pos
group by 1 
order by 1;

select treatment, count(distinct user_id) as neg_user_count
from ab_test_neg
GROUP BY 1 
ORDER BY 1;
